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
    
    // Extract audio from video file and asynchronously return result in a closure
    extractAudio(fromVideoFile: videoURL) { audioURL, error in
        if audioURL != nil {
            print("Extracted audio file has URL path: \(audioURL!)")
            
            // Transcribe audio using a Speech to Text API and asynchronously return result in a closure
            //transcribeAudio(ofAudioFile: audioURL!) { transcriptionData, error in
            
            // Upload audio to cloud
            uploadAudioToCloud(withURL: audioURL!)
                
            //}
        }
        else if error != nil {
            print(error!)
        }
    }
    

    
    // Form captions from the transcribed data
    //var captionData: [Caption]
    //captionData = formCaptions(fromData: transcriptionData)
    
    return captionData
}

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
            completionHandler(outputURL, nil)
        }
    }
    return
}

func uploadAudioToCloud(withURL audioURL: URL) {
    
    // Assign a random identifier to be used in the bucket and reference the file in the bucket
    let randomID = UUID.init().uuidString
    let uploadRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-audio/\(randomID).m4a")
    
    // Create file metadata
    let uploadMetadata = StorageMetadata.init()
    uploadMetadata.contentType = "audio/m4a"
    
    // Do a PUT request to upload the file and check for errors
    uploadRef.putFile(from: audioURL, metadata: uploadMetadata) { (downloadMetadata, error) in
        if let error = error {
            print("Error uploading audio file! \(error.localizedDescription)")
            return
        }
        print("PUT is complete. Successful response from server is: \(downloadMetadata)")
    }
    
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
    var captionData: [Caption] = []
    // Insert code to form captions from a JSON structured API response
    
    return captionData
}
