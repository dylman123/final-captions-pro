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

class UserData: ObservableObject {
    
    // Boolean values to handle the logic of showing the task pane
    @Published var showTaskPane: Bool = true
    @Published var showFileInput: Bool = true
    @Published var showProgressBar: Bool = false

    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption] = captionSampleData
    //@Published var captions: [Caption] = generateCaptions() // when function is set up
    
    // Generates captions by using a transcription service
    func _generateCaptions(forFile videoPath: URL) {
        self.captions = generateCaptions(forFile: videoPath) ?? []
        //print(self.captions)
    }
    
    // Adds a blank caption into the row above the selected cell
    // The new caption's end time will match the caller caption's start time
    func _addCaption(beforeIndex id: Int, atTime end: Float) {
        self.captions = addCaption(toArray: self.captions, beforeIndex: id, atTime: end)
    }
    
    // Deletes the selected cell
    func _deleteCaption(atIndex id: Int) {
        self.captions = deleteCaption(fromArray: self.captions, atIndex: id)
    }
}
