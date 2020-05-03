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

class UserData: NSObject, ObservableObject, XMLParserDelegate {
    
    // Boolean values to handle the logic of showing the task pane
    @Published var showTaskPane: Bool = false
    @Published var showFileInput: Bool = true
    @Published var showProgressBar: Bool = false

    // The global array which is to be generated via transcription API and edited by the user
    //@Published var captions: [Caption] = []
    @Published var captions: [Caption] = sampleCaptionData
    
    // Generates captions by using a transcription service
    func _generateCaptions(forFile videoURL: URL) -> Void {
        
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
               
        //  Create XML document structure
        let xmlTree = createXML(from: self.captions)
        
        //  Save XML document to disk
        saveXML(of: xmlTree, as: xmlPath)
        
        //  Open newly saved XML document in FCP X
        //openXML(at: xmlPath)
        
    }
    
}
