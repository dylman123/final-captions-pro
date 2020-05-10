//
//  UserData.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import SwiftUI
import Combine
import Firebase

class UserData: NSObject, ObservableObject, XMLParserDelegate {
    
    // Boolean values to handle the logic of showing the task pane
    @Published var showTaskPane: Bool = true
    @Published var showFileInput: Bool = true
    @Published var showProgressBar: Bool = false

    // The global array which is to be generated via transcription API and edited by the user
    //@Published var captions: [Caption] = []
    @Published var captions: [Caption] = sampleCaptionData
    
    // A store of the imported video's URL
    private var videoURL: URL = URL(fileURLWithPath: "")
    
    // Stores the videoURL and calls _generateCaptions() function
    func _import(videoFile videoURL: URL) -> Void {
        self.videoURL = videoURL
        _generateCaptions(forFile: videoURL)
    }
    
    // Generates captions by using a transcription service
    func _generateCaptions(forFile videoURL: URL) -> Void {
        
        var captionData: [Caption]?
        
        // Semaphore for asynchronous tasks
        let semaphore = DispatchSemaphore(value: 0)
        
        // Run on a background thread
        DispatchQueue.global().async {
            
            // Extract audio from video file
            var m4aURL: URL?
            do {
                m4aURL = try extractAudio(fromVideoFile: videoURL)
                semaphore.signal()
            } catch {
                print("Error extracting audio from video file: \(error): \(error.localizedDescription)")
                return
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            // Convert .m4a file to .wav format
            var wavURL: URL?
            do {
                wavURL = try convertM4AToWAV(inputURL: m4aURL!)
                semaphore.signal()
            } catch {
                print("Error converting .m4a to .wav format: \(error.localizedDescription)")
                return
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
                return
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            // Short poll the remote server to download captions JSON from Google Cloud Storage
            let timeout: Int = 60  // in secs
            let pollPeriod: Int = 10  // in secs
            var secondsElapsed: Int = 0
            var jsonRef: StorageReference?
            var downloadError: Error?
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
                return
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            // Delete temporary audio file from bucket in Google Cloud Storage
            do {
                try deleteTempFiles(audio: audioRef!, captions: jsonRef!)
            } catch {
                print("Error deleting temp file(s) from Google Cloud Storage:  \(error.localizedDescription)")
            }
        
            // Update views with new data
            DispatchQueue.main.async {
                if captionData != nil {
                    self.captions = captionData!
                } else {
                    self.captions = initialCaptionsList
                }
            }
        }
    }
    
    // Adds a blank caption into the row above the selected cell. The new caption's end time will match the caller caption's start time
    func _addCaption(beforeIndex id: Int, atTime end: Float) -> Void {
        self.captions = addCaption(toArray: self.captions, beforeIndex: id, atTime: end)
        print(self.captions)
    }
    
    // Deletes the selected cell
    func _deleteCaption(atIndex id: Int) -> Void {
        self.captions = deleteCaption(fromArray: self.captions, atIndex: id)
        print(self.captions)
    }
    
    // Finishes the caption review and opens .fcpxml file
    func _finishReview(andSaveFileAs xmlPath: URL) -> Void {
        
        // Set the path of the file to be saved - TODO: Change this to a user selected URL
        let testPath = getDocumentsDirectory().appendingPathComponent("test.fcpxml")
               
        //  Create XML document structure
        let xmlTree = createXML(forVideo: self.videoURL, withCaptions: self.captions)

        //  Save XML document to disk
        saveXML(of: xmlTree, as: testPath)
        
        //  Open newly saved XML document in Final Cut Pro X
        openXML(at: testPath)
        
    }
    
}
