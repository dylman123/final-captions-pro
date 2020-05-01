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

// generateCaptions() is the top level function which is called upon video file import.
//   - Input: Video filepath URL
//   - Output: Array of Caption objects, returned as captionData
func generateCaptions(forFile videoURL: URL) -> [Caption] {
    
    // Check format conversion compatibility (to m4a)
    let videoAsset = AVURLAsset(url: videoURL)
    AVAssetExportSession.determineCompatibility(ofExportPreset: AVAssetExportPresetPassthrough, with: videoAsset, outputFileType: AVFileType.m4a, completionHandler: { result in
        guard result else {
            print("Video file cannot be converted to .m4a format.")
            return
        }
    })
    
    // Extract audio from video file and asynchronously return result in a closure
    extractAudio(fromVideoFile: videoURL) { m4aURL, error in
        
        if m4aURL != nil {

            // Convert .m4a file to .wav format
            let wavURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
            convertM4AToWAV(inputURL: m4aURL!, outputURL: wavURL)
            print("WAV audio located at: \(wavURL)")
            
            // Upload audio to Google Cloud Storage
            uploadAudioToCloud(withURL: wavURL) { fileID, error in
                
                if fileID != nil {
                    
                    // Download captions file from Google Cloud Storage
                    do { sleep(10) }
                    downloadCaptions(withFileID: fileID!) { captions, error in
                        
                    }
                }
            }
            
            // Create a longpolling request to be asynchronously notified when JSON file is ready for download
            //let longPollDelegate: LongPollingDelegate = LongPollingDelegate()
            //let request = LongPollingRequest(delegate: longPollDelegate)
            
                
            //}
        }
    }
    
    // Form captions from the transcribed data
    //var captionData: [Caption]
    //captionData = formCaptions(fromData: transcriptionData)
    
    return captionData
}

// Extract audio from video file and asynchronously return result in a closure
func extractAudio(fromVideoFile sourceURL: URL, completionHandler: @escaping (URL?, Error?) -> Void) {
    // Create a composition
    let composition = AVMutableComposition()
    do {
        // Creat an AVAsset from the video's sourceURL
        let asset = AVURLAsset(url: sourceURL)
        guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
        guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
    } catch {
        print("Error extracting audio from video file: \(error.localizedDescription)")
        completionHandler(nil, error)
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

        DispatchQueue.main.async {
            guard let outputURL = exportSession.outputURL else { return }
            print("Extracted audio file has URL path: \(outputURL)")
            completionHandler(outputURL, nil)
        }
    }
    return
}

// Convert .m4a file to .wav format
func convertM4AToWAV(inputURL: URL, outputURL: URL) {
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
    print("Error 1 in convertAudio: \(error.description)")

    error = ExtAudioFileSetProperty(sourceFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Error 2 in convertAudio: \(error.description)")

    error = ExtAudioFileSetProperty(destinationFile!,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat)
    print("Error 3 in convertAudio: \(error.description)")

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
        print("Error 4 in convertAudio: \(error.description)")

        if(numFrames == 0){
            error = noErr;
            break;
        }

        sourceFrameOffset += numFrames
        error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
        print("Error 5 in convertAudio: \(error.description)")
    }

    error = ExtAudioFileDispose(destinationFile!)
    print("Error 6 in convertAudio: \(error.description)")
    error = ExtAudioFileDispose(sourceFile!)
    print("Error 7 in convertAudio: \(error.description)")
}

// Upload audio to Google Cloud Storage
func uploadAudioToCloud(withURL audioURL: URL, completionHandler: @escaping (String?, Error?) -> Void) {
    
    // Assign a random identifier to be used in the bucket and reference the file in the bucket
    let randomID = UUID.init().uuidString
    let uploadRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-audio/\(randomID).wav")
    
    // Create file metadata
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "audio/wav"
    
    // Do a PUT request to upload the file and check for errors
    uploadRef.putFile(from: audioURL, metadata: uploadMetadata) { (downloadMetadata, error) in
        if let error = error {
            print("Error uploading audio file! \(error.localizedDescription)")
            completionHandler(nil, error)
        }
        else {
            print("PUT is complete. Successful response from server is: \(downloadMetadata!)")
            completionHandler(randomID, nil)
        }
    }
    
}

func downloadCaptions(withFileID fileID: String, completionHandler: @escaping ([Caption]?, Error?) -> Void) {
    var captions: [Caption]
    
    // Do a GET request to download the captions file and check for errors
    let storageRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-captions/\(fileID).json")
    storageRef.getData(maxSize: 1024 * 1024, completion: { (data, error) in
        if let error = error {
            print("Error downloading captions file! \(error.localizedDescription)")
            completionHandler(nil, error)
        }
        else {
            print(data!)
            //completionHandler(captions, nil)
            completionHandler(nil, nil)
        }
    })
}

func transcribeAudio(ofAudioFile audioPath: URL, completionHandler: @escaping ([String:Any]?, Error?) -> Void) {
  
    // URL
    let url = URL(string: "https://rev-ai.p.rapidapi.com/jobs")
    guard url != nil else {
        print("Error creating URL object.")
        return
    }
    
    // URL Request
    var request = URLRequest(url: url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
    
    // Specify the header
    let headers = [
        "x-rapidapi-host": "rev-ai.p.rapidapi.com",
        "x-rapidapi-key": "378f1cde96mshdf2795f0e8ff706p12ee5bjsne932a0f04d18",
        "content-type": "application/json",
        "accept": "application/json"
    ]
    request.allHTTPHeaderFields = headers
    
    // Specify the body
    let parameters: [String:Any] = [
        "media_url": "https://support.rev.com/hc/en-us/article_attachments/200043975/FTC_Sample_1_-_Single.mp3",
        "metadata": "Optional metadata associated with the job",
        "callback_url": "https://www.example.com/callback"
    ]
    do {
        let requestBody = try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        request.httpBody = requestBody
    } catch {
        print("Error creating the data object from the JSON object.")
    }
    
    // Set the request type
    request.httpMethod = "POST"
    
    // Get the URLSession
    let session = URLSession.shared
    
    // Create the data task
    let dataTask = session.dataTask(with: request) { (data, response, error) in
        
        // Check for errors
        if error == nil && data != nil {
            
            // Try to parse out the data
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String:Any]
                print(dictionary!)
            } catch {
                print("Error parsing response data.")
            }
        }
        
    }
    
    // Fire off the data task
    dataTask.resume()
    
    return
}

func formCaptions(fromData transcriptionData: [String:String]) -> [Caption] {
    let captionData: [Caption] = []
    // Insert code to form captions from a JSON structured API response
    
    return captionData
}
