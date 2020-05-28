//
//  GenerateCaptions.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//
import Foundation
import AVFoundation
import Firebase

// Generates captions by using a transcription service
func generateCaptions(forFile videoURL: URL) -> [Caption] {
    
    // Semaphore for asynchronous tasks
    let semaphore = DispatchSemaphore(value: 0)
    
    // Run on a background thread
    //DispatchQueue.global().async {
        
    // Extract audio from video file
    var m4aURL: URL?
    do {
        m4aURL = try extractAudio(fromVideoFile: videoURL)
        semaphore.signal()
    } catch {
        print("Error extracting audio from video file: \(error): \(error.localizedDescription)")
        return initialCaptionsList
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Convert .m4a file to .wav format
    var wavURL: URL?
    do {
        wavURL = try convertM4AToWAV(inputURL: m4aURL!)
        semaphore.signal()
    } catch {
        print("Error converting .m4a to .wav format: \(error.localizedDescription)")
        return initialCaptionsList
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Upload audio to Google Cloud Storage
    var audioRef: StorageReference?
    var fileID: String?
    do {
        (audioRef, fileID) = try uploadAudio(withURL: wavURL!)
        semaphore.signal()
    } catch {
        print("Error uploading audio file: \(error.localizedDescription)")
        return initialCaptionsList
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Short poll the remote server to download captions JSON from Google Cloud Storage
    let timeout: Int = 60  // in secs
    let pollPeriod: Int = 5  // in secs
    var secondsElapsed: Int = 0
    var jsonRef: StorageReference?
    var downloadError: Error?
    var captionData: [Caption]?
    repeat {
        do {
            sleep(UInt32(pollPeriod))
            secondsElapsed += pollPeriod
            (jsonRef, captionData) = try downloadCaptions(withFileID: fileID!)
            semaphore.signal()
        } catch {
            downloadError = error
            print("seconds elapsed: \(secondsElapsed). Will poll server again in \(pollPeriod) seconds...")
        }
    } while ( jsonRef == nil && secondsElapsed < timeout )
    // Error handling
    guard jsonRef != nil else {
        print("Error downloading captions file: \(downloadError!.localizedDescription)")
        return initialCaptionsList
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Delete temporary audio file from bucket in Google Cloud Storage
    do {
        try deleteTempFiles(audio: audioRef!, captions: jsonRef!)
    } catch {
        print("Error deleting temp file(s) from Google Cloud Storage:  \(error.localizedDescription)")
    }
    
    if captionData != nil {
        return captionData!
    } else {
        return initialCaptionsList
    }
    //}
}

// Extract audio from video file
func extractAudio(fromVideoFile sourceURL: URL?) throws -> URL? {
    
    enum ExtractAudioError: Error {
        case url
        case format
        case AVAsset
        case composition
        case export
    }
    
    // Semaphore for asynchronous tasks
    let semaphore = DispatchSemaphore(value: 0)
    
    guard let url = sourceURL else {
        throw ExtractAudioError.url
    }
    
    // Check format conversion compatibility (to m4a)
    let videoAsset = AVURLAsset(url: url)
    var isCompatibleWithM4A: Bool?
    AVAssetExportSession.determineCompatibility(ofExportPreset: AVAssetExportPresetPassthrough, with: videoAsset, outputFileType: AVFileType.m4a, completionHandler: { result in
            DispatchQueue.main.async {
                isCompatibleWithM4A = result
                semaphore.signal()
            }
        })

    _ = semaphore.wait(timeout: .distantFuture)
    guard isCompatibleWithM4A == true else {
        throw ExtractAudioError.format
    }
    
    // Creat an AVAsset from the video's sourceURL
    let asset = AVURLAsset(url: url)
    guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else
    { throw ExtractAudioError.AVAsset }
    
    // Create a composition
    let composition = AVMutableComposition()
    guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else
    { throw ExtractAudioError.composition }
    do {
        try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
    } catch {
        throw ExtractAudioError.composition
    }
    
    // Get URL for output
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "extracted-audio.m4a")
    if FileManager.default.fileExists(atPath: outputURL.path) {
        try? FileManager.default.removeItem(atPath: outputURL.path)
    }
    
    // Create an export session
    let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
    exportSession.outputFileType = AVFileType.m4a
    exportSession.outputURL = outputURL
    
    // Export file
    exportSession.exportAsynchronously {
        guard case exportSession.status = AVAssetExportSession.Status.completed else { return }
        guard let outputURL = exportSession.outputURL else { return }
        print("Extracted audio file has URL path: \(outputURL)")
        semaphore.signal()
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    return outputURL
}

// Convert .m4a file to .wav format
func convertM4AToWAV(inputURL: URL) throws -> URL? {
    enum convertError: Error {
        case convert
    }
    var error : OSStatus = noErr
    var destinationFile: ExtAudioFileRef? = nil
    var sourceFile : ExtAudioFileRef? = nil

    var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
    var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()

    ExtAudioFileOpenURL(inputURL as CFURL, &sourceFile)

    var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))

    ExtAudioFileGetProperty(sourceFile!,
                            kExtAudioFileProperty_FileDataFormat,
                            &thePropertySize, &srcFormat)

    dstFormat.mSampleRate = 44100  //Set sample rate
    dstFormat.mFormatID = kAudioFormatLinearPCM
    dstFormat.mChannelsPerFrame = 1
    dstFormat.mBitsPerChannel = 16
    dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
    dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
    dstFormat.mFramesPerPacket = 1
    dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
    kAudioFormatFlagIsSignedInteger

    // Create destination file
    let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
    error = ExtAudioFileCreateWithURL(
        outputURL as CFURL,
        kAudioFileWAVEType,
        &dstFormat,
        nil,
        AudioFileFlags.eraseFile.rawValue,
        &destinationFile)
    print("Status 1 in convertAudio: \(error.description)")

    error = ExtAudioFileSetProperty(sourceFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Status 2 in convertAudio: \(error.description)")

    error = ExtAudioFileSetProperty(destinationFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Status 3 in convertAudio: \(error.description)")

    let bufferByteSize : UInt32 = 32768
    var srcBuffer = [UInt8](repeating: 0, count: 32768)
    var sourceFrameOffset : ULONG = 0

    while(true){
        var fillBufList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels: 2,
                mDataByteSize: UInt32(srcBuffer.count),
                mData: &srcBuffer
            )
        )
        var numFrames : UInt32 = 0

        if(dstFormat.mBytesPerFrame > 0){
            numFrames = bufferByteSize / dstFormat.mBytesPerFrame
        }

        error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
        print("Status 4 in convertAudio: \(error.description)")

        if(numFrames == 0){
            error = noErr;
            break;
        }

        sourceFrameOffset += numFrames
        error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
        print("Status 5 in convertAudio: \(error.description)")
    }

    error = ExtAudioFileDispose(destinationFile!)
    print("Status 6 in convertAudio: \(error.description)")
    error = ExtAudioFileDispose(sourceFile!)
    print("Status 7 in convertAudio: \(error.description)")
    
    // Handle the result / error
    if error == 0 {
        print("Succcessfully saved .wav audio as: \(outputURL)")
        return outputURL
    } else {
        throw convertError.convert
    }
}

// Upload audio to Google Cloud Storage where a Firebase transcription function will be triggered
func uploadAudio(withURL audioURL: URL) throws -> (StorageReference?, String?) {
    
    // Semaphore for asynchronous tasks
    let semaphore = DispatchSemaphore(value: 0)
    
    // Assign a random identifier to be used in the bucket and reference the file in the bucket
    let randomID = UUID.init().uuidString
    let uploadRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-audio/\(randomID).wav")
    
    // Create file metadata
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "audio/wav"
    
    // Do a PUT request to upload the file and check for errors
    print("Uploading audio to the cloud...")
    var downloadMetadata: StorageMetadata?
    var error: Error?
    
    uploadRef.putFile(from: audioURL, metadata: uploadMetadata) { (md, err) in  //FIXME: Sometimes never executes because of the semaphore.wait()
        if let err = err { error = err }
        else { downloadMetadata = md }
        semaphore.signal()
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Handle the result / error
    if downloadMetadata != nil {
        print("PUT is complete. Successful response from server is: \(downloadMetadata!)")
        return (uploadRef, randomID)
    }
    else {
        throw error!
    }
}

// Download captions file from Google Cloud Storage
func downloadCaptions(withFileID fileID: String) throws -> (StorageReference? , [Caption]?) {
    
    var captionsArray: [Caption]?
    
    // Semaphore for asynchronous tasks
    let semaphore = DispatchSemaphore(value: 0)

    // Do a GET request to download the captions file and check for errors
    let storageRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-captions/\(fileID).json")
    var responseData: Data?
    var downloadError: Error?
    storageRef.getData(maxSize: 1024 * 1024) { (data, error) in
        if let error = error { downloadError = error }
        else { responseData = data! }
        semaphore.signal()
    }
    
    _ = semaphore.wait(timeout: .distantFuture)
    
    // Handle the result / error
    if responseData != nil {
        print("Captions file succesfully downloaded.")
    } else { throw downloadError! }
    
    // Parse downloaded response as JSON
    let decoder = JSONDecoder()
    do {
        let result = try decoder.decode(JSONResult.self, from: responseData!)
        captionsArray = result.captions
        print("Successfully parsed JSON: \(captionsArray!)")
        return (storageRef, captionsArray)
    } catch {
        let JSONParseError: Error = error
        throw JSONParseError
    }
}

// Delete temporary audio file from bucket in Google Cloud Storage
func deleteTempFiles(audio audioRef: StorageReference, captions jsonRef: StorageReference) throws -> Void {
    
    enum deleteError: Error {
        case audio
        case json
        case both
    }
    
    var audioError: Error?
    var jsonError: Error?
    
    // Semaphore for asynchronous tasks
    let audioSem = DispatchSemaphore(value: 0)
    let jsonSem = DispatchSemaphore(value: 0)
    
    // Delete audio file
    audioRef.delete { error in
        if let error = error { audioError = error }
        audioSem.signal()
    }

    // Delete JSON file
    jsonRef.delete { error in
        if let error = error { jsonError = error }
        jsonSem.signal()
    }
    
    // Make synchronous
    _ = audioSem.wait(timeout: .distantFuture)
    _ = jsonSem.wait(timeout: .distantFuture)
    
    // Handle the result / error
    if (audioError == nil) && (jsonError == nil) {
        print("Successfully deleted temporary files from Google Cloud Storage.")
    }
    else if (audioError != nil) && (jsonError == nil) {
        throw deleteError.audio
    }
    else if (audioError == nil) && (jsonError != nil) {
        throw deleteError.json
    }
    else if (audioError != nil) && (jsonError != nil) {
        throw deleteError.both
    }
}
