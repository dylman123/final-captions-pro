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
    @Published var captions: [Caption] = sampleCaptionData
    
    // The mode of the app when editing captions
    @Published var mode: Mode = .pause
    
    // An index which represents the selected caption
    @Published var selectionIndex = 0
    
    // URL of the imported video
    var videoURL: URL = URL(fileURLWithPath: "")
    
}

var sampleCaptionData: [Caption] = load("captionDataLong")
