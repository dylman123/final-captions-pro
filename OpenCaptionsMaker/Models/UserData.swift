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
        
        // Extract audio from video file
        var m4aURL: URL?
        do {
            m4aURL = try extractAudio(fromVideoFile: videoURL)
        } catch {
            print("Error extracting audio from video file: \(error): \(error.localizedDescription)")
            return
        }
                
        // Convert .m4a file to .wav format
        guard m4aURL != nil else { return }
        let wavURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
        convertM4AToWAV(inputURL: m4aURL!, outputURL: wavURL)
        
        // Upload audio to Google Cloud Storage
        var audioRef: StorageReference?
        var fileID: String?
        do {
            (audioRef, fileID) = try uploadAudio(withURL: wavURL)
        } catch {
            print("Error uploading audio file! \(error.localizedDescription)")
            return
        }
        
        // Download captions file from Google Cloud Storage
        do { sleep(10) }  // TODO: Make this a websockets callback to the Firebase DB
        var captionData: [Caption]?
        do {
            captionData = try downloadCaptions(withFileID: fileID!)
        } catch {
            print("Error downloading captions file! \(error.localizedDescription)")
            return
        }
        
        // Delete temporary audio file from bucket in Google Cloud Storage
        do {
            try deleteAudio(withStorageRef: audioRef!)
        } catch {
            print("Error deleting audio file from Google Cloud Storage:  \(error.localizedDescription)")
        }
        
        // Set self.captions variable
        if captionData != nil {
            self.captions = captionData!
        } else {
            self.captions = []
        }
        
        // Extract audio from video file and asynchronously return result in a closure
        /*extractAudio(fromVideoFile: videoURL) { m4aURL, error in
            if m4aURL != nil {

                // Convert .m4a file to .wav format
                let wavURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
                convertM4AToWAV(inputURL: m4aURL!, outputURL: wavURL)
                
                // Upload audio to Google Cloud Storage
                uploadAudio(withURL: wavURL) { audioRef, fileID, error in
                    if fileID != nil {
                        
                        // Download captions file from Google Cloud Storage by short polling the server
                        do { sleep(10) }  // TODO: Make this a websockets callback to the Firebase DB
                        downloadCaptions(withFileID: fileID!) { captionData, error in
                            if captionData != nil {
                                self.captions = captionData!
                                print(self.captions)
                                //deleteAudio(withStorageRef: audioRef!) //FIXME: This is messing up the upload step (multithread issue!)
                            } else { self.captions = [] }
                            
                            return
                        }
                    }
                }
            }
        }*/
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
