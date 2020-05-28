//
//  AppState.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import Combine

enum Mode {
    case play, pause, edit, editStartTime, editEndTime
}

class AppState: ObservableObject {
    
    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption]
    
    // The mode of the app when editing captions
    @Published var mode: Mode
    
    // An index which represents the selected caption
    @Published var selectionIndex: Int
    
    // URL of the imported video
    var videoURL: URL = URL(fileURLWithPath: "")
    
    init(captionArray captions: [Caption] = sampleCaptionData, mode: Mode = .pause, selectionIndex: Int = 0) {
        self.captions = captions
        self.mode = mode
        self.selectionIndex = selectionIndex
    }
    
}

var sampleCaptionData: [Caption] = load("captionDataLong")
