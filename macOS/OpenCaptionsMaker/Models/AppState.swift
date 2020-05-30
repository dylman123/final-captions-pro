//
//  AppState.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import Combine
import SwiftUI

enum Mode {
    case play, pause, edit, editStartTime, editEndTime
}

class AppState: ObservableObject {
    
    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption] = sampleCaptionData
    
    // The mode of the app when editing captions
    @Published var mode: Mode = .pause
    
    // The video's current playback position (fraction between 0 to 1)
    @Published var videoPos: Double = 0.0
    @Published var videoDuration: Double = 0.0
    @Published var videoTime: Double = 0.0
    
    // An index which represents the selected caption
    @Published var selectedIndex: Int = 0
    
    // URL of the imported video
    var videoURL: URL = URL(fileURLWithPath: "")
    
    // Set state within the application
    func transition(to newState: Mode) -> Void {
        mode = newState
        let notification = NSNotification.Name(String(describing: newState))
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    /*init(captions: [Caption] = sampleCaptionData,
         mode: Mode = .pause,
         //videoTime: Double = 0.0,
         selectionIndex: Int = 0) {
            self.captions = captions
            self.mode = mode
            //self.videoTime = videoTime
            self.selectionIndex = selectionIndex
    }*/
    
}

var sampleCaptionData: [Caption] = load("captionDataLong")
