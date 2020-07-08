//
//  Transcriber.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import AVFoundation
import Combine
import Firebase

enum TranscriptionState {
    case idle
    case selectedVideo(Result<URL, APIError>)
    case extractedAudio(Result<URL, APIError>)
    case convertedAudio(Result<URL, APIError>)
    case uploadedAudio(Result<String, APIError>)
    case downloadedJSON(Result<String, APIError>)
    case deletedTemp(Result<String, APIError>)
}

enum APIError: Error {
    case error(String)

    var localizedDescription: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}

class Transcriber: ObservableObject {
    
    // Transcription properties
    @Published var state: TranscriptionState = .idle
    @Published var video: URL?
    @Published var audioRef: StorageReference?
    @Published var jsonRef: StorageReference?
    @Published var captions: [Caption]?
    private var readyStatus = [true, false, false, false, false, false]

    // Top level function
    func generateCaptions(forFile url: URL) {
        guard readyStatus[0] == true else { return }
        
        readyStatus[1] = true
        DispatchQueue.main.async { [weak self] in
            self?.video = url
            self?.state = .selectedVideo(.success(url))
        }
    }
        
    // Extract audio from video file and asynchronously return result in a closure
    func extractAudio(fromFile sourceURL: URL) {
        guard readyStatus[1] == true else { return }
        
        // Check format conversion compatibility (to m4a)
        let videoAsset = AVURLAsset(url: sourceURL)
        AVAssetExportSession.determineCompatibility(ofExportPreset: AVAssetExportPresetPassthrough, with: videoAsset, outputFileType: AVFileType.m4a, completionHandler: { result in
            guard result else {
                print("Video file cannot be converted to .m4a format.")
                return
            }
        })
        
        // Create a composition
        let composition = AVMutableComposition()
        do {
            // Creat an AVAsset from the video's sourceURL
            let asset = AVURLAsset(url: sourceURL)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.state = .extractedAudio(.failure(.error("Error extracting audio from video file: \(error.localizedDescription)")))
            }
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
            DispatchQueue.main.async { [weak self] in
                self?.readyStatus[2] = true
                self?.state = .extractedAudio(.success(outputURL))
            }
        }
        return
    }

    // Convert .m4a file to .wav format
    func convertAudio(forFile inputURL: URL) {
        guard readyStatus[2] == true else { return }
        
        let outputURL: URL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
        
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
        
        DispatchQueue.main.async { [weak self] in
            if error == 0 {
                self?.readyStatus[3] = true
                self?.state = .convertedAudio(.success(outputURL))
            }
            else {
                self?.state = .convertedAudio(.failure(.error("Error converting audio to .wav format: \(error.description)")))
            }
        }
    }

    // Upload audio to Google Cloud Storage where a Firebase transcription function will be triggered
    func uploadAudio(fromFile audioURL: URL) {
        guard readyStatus[3] == true else { return }
        readyStatus[3] = false
        
        // Assign a random identifier to be used in the bucket and reference the file in the bucket
        let randomID = UUID.init().uuidString
        let uploadRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-audio/\(randomID).wav")
        audioRef = uploadRef
        
        // Create file metadata
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "audio/wav"
        
        // Do a PUT request to upload the file and check for errors
        print("Uploading audio to the cloud...")
        uploadRef.putFile(from: audioURL, metadata: uploadMetadata) { (downloadMetadata, error) in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.state = .uploadedAudio(.failure(.error("Error uploading audio file! \(error.localizedDescription)")))
                }
                else {
                    print("PUT is complete. Successful response from server is: \(downloadMetadata!)")
                    self?.readyStatus[4] = true
                    self?.state = .uploadedAudio(.success(randomID))
                }
            }
        }
        
    }

    // Download captions file from Google Cloud Storage
    func downloadCaptions(withID fileID: String) {
        guard readyStatus[4] == true else { return }
        readyStatus[4] = false
        
        // Do a GET request to download the captions file and check for errors
        let storageRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-captions/\(fileID).json")
        jsonRef = storageRef
        
        storageRef.getData(maxSize: 1024 * 1024) { (data, error) in
            
            // If there is an error in downloading the file
            if let error = error {
                if error.localizedDescription.contains("json does not exist.") {
                    print("File not ready. Trying again in 5 secs...")
                    sleep(5)  // polling period
                    self.readyStatus[4] = true
                    self.downloadCaptions(withID: fileID)  // Recursively try again
                }
                else {
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .downloadedJSON(.failure(.error("Error downloading captions file! \(error.localizedDescription)")))
                    }
                }
            }
            else {
                print("Captions file succesfully downloaded.")
                let decoder = JSONDecoder()
                do {
                    // Parse downloaded response as JSON
                    let result = try decoder.decode(JSONResult.self, from: data!)
                    let downloadedCaptions = result.captions
                    self.adjustCaptionTimings(captions: downloadedCaptions)
                    DispatchQueue.main.async { [weak self] in
                        self?.readyStatus[5] = true
                        self?.state = .downloadedJSON(.success("Successfully parsed JSON."))
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.state = .downloadedJSON(.failure(.error("Error parsing JSON! \(error.localizedDescription)")))
                    }
                }
            }
        }
    }

    // Adjust timing for better readability / usability
    func adjustCaptionTimings(captions: [Caption]) {
        var array = captions
        let buffer: Float = 0.5  // the time for a caption to linger if followed by a pause (in seconds)
        let offset: Float = 0.1  // a fixed delay to add to every caption (in seconds)
        let minDuration: Float = 0.5  // allows for better UX and readability (in seconds)
        
        for idx in 0..<array.count {
            // If not the last caption in the array
            if idx != array.count-1 {
                // Linger caption to fill gap in audio
                if array[idx].end + buffer < array[idx+1].start {
                    array[idx].end += buffer
                } else { array[idx].end = array[idx+1].start }
            }
            // Translate each caption forward by a fixed offset
            array[idx].start += offset
            array[idx].end += offset
            
            // Adjust duration values
            array[idx].duration = array[idx].end - array[idx].start
            if array[idx].duration < minDuration {  // Ensure minimum duration
                array[idx].end = array[idx].start + minDuration
                array[idx].duration = minDuration
            }
        }
        self.captions = array
    }
    
    // Delete temporary files from bucket in Google Cloud Storage
    func deleteTempFiles() {
        guard readyStatus[5] == true else { return }
        readyStatus[5] = false
        
        audioRef!.delete { error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.state = .deletedTemp(.failure(.error("Error deleting audio file from Google Cloud Storage: \(error.localizedDescription)")))
                } else {
                    self?.state = .deletedTemp(.success("Successfully deleted audio file from Google Cloud Storage."))
                }
            }
        }
        
        jsonRef!.delete { error in
            DispatchQueue.main.async { [weak self] in
                if let error = error {
                    self?.state = .deletedTemp(.failure(.error("Error deleting JSON file from Google Cloud Storage: \(error.localizedDescription)")))
                } else {
                    self?.state = .deletedTemp(.success("Successfully deleted JSON file from Google Cloud Storage."))
                }
            }
        }
    }
}
