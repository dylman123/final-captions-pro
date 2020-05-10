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

class UserData: ObservableObject {
    
    // Boolean values to handle the logic of showing the task pane
    @Published var showTaskPane: Bool = true
    @Published var showFileInput: Bool = true
    @Published var showProgressBar: Bool = false

    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption] = []
    
    // Adds a blank caption into the row above the selected cell
    // The new caption's end time will match the caller caption's start time
    func _addCaption(beforeIndex id: Int, atTime end: Float) {
        self.captions = addCaption(toArray: self.captions, beforeIndex: id, atTime: end)
        print(self.captions)
    }
    
    // Deletes the selected cell
    func _deleteCaption(atIndex id: Int) {
        self.captions = deleteCaption(fromArray: self.captions, atIndex: id)
        print(self.captions)
    }
    
    // Generates captions by using a transcription service
    func _generateCaptions(forFile videoURL: URL) -> Void {
        
<<<<<<< HEAD:OpenCaptionsMaker/Models/UserData.swift
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
            
            // Download captions file from Google Cloud Storage
            do { sleep(10) }  // TODO: Make this a websockets callback to the Firebase DB
            do {
                captionData = try downloadCaptions(withFileID: fileID!)
                semaphore.signal()
            } catch {
                print("Error downloading captions file: \(error.localizedDescription)")
                return
            }
            
            _ = semaphore.wait(timeout: .distantFuture)
            
            // Delete temporary audio file from bucket in Google Cloud Storage
            do {
                try deleteAudio(withStorageRef: audioRef!)
            } catch {
                print("Error deleting audio file from Google Cloud Storage:  \(error.localizedDescription)")
            }
        
            // Update views with new data
            DispatchQueue.main.async {
                if captionData != nil {
                    self.captions = captionData!
                } else {
                    self.captions = initialCaptionsList
=======
        // Extract audio from video file and asynchronously return result in a closure
        extractAudio(fromVideoFile: videoURL) { m4aURL, error in
            if m4aURL != nil {

                // Convert .m4a file to .wav format
                let wavURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
                convertM4AToWAV(inputURL: m4aURL!, outputURL: wavURL)
                
                // Upload audio to Google Cloud Storage
                uploadAudio(withURL: wavURL) { fileID, error in
                    if fileID != nil {
                        
                        // Download captions file from Google Cloud Storage by short polling the server
                        do { sleep(10) }  // TODO: Make this a websockets callback to the Firebase DB
                        downloadCaptions(withFileID: fileID!) { captionData, error in
                            if captionData != nil {
                                self.captions = captionData!
                            } else { self.captions = [] }
                            print(self.captions)
                            return
                        }
                    }
>>>>>>> 14390de562f1ac531c24b2e985ce068aa789de6d:macOS/OpenCaptionsMaker/Models/UserData.swift
                }
            }
        }
    }
}
