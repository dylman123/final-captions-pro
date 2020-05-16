//
//  UserData.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import Combine

class UserData: ObservableObject {
    
    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption] = sampleCaptionData
    
    // A store of the imported video's URL
    var videoURL: URL = URL(fileURLWithPath: "")
    
    /*// Stores the videoURL and calls generateCaptions() function
    func _import(videoFile videoURL: URL) -> Void {
        self.videoURL = videoURL
        self.captions = generateCaptions(forFile: videoURL)
    }*/
    
    // Adds a blank caption into the row above the selected cell. The new caption's end time will match the caller caption's start time
    /*func _addCaption(beforeIndex id: Int, atTime end: Float) -> Void {
        self.captions = addCaption(toArray: self.captions, beforeIndex: id, atTime: end)
    }*/
    
    /*// Deletes the selected cell
    func _deleteCaption(atIndex id: Int) -> Void {
        self.captions = deleteCaption(fromArray: self.captions, atIndex: id)
    }*/
    
}
