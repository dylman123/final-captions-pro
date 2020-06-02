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
    
    // The progress through the video, as a percentage (from 0 to 1)
    @Published var videoPos: Double = 0.0
    
    // The duration of the video in seconds
    @Published var videoDuration: Double = 0.0
    
    // An index which represents the selected caption
    @Published var selectedIndex: Int = 0
    
    // URL of the imported video
    @Published var videoURL: URL = URL(fileURLWithPath: "")
    
    // Set state within the application
    func transition(to newState: Mode) -> Void {
        mode = newState
        let notification = NSNotification.Name(String(describing: newState))
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    // Sync video playback with list index
    func syncVideoAndList(isListControlling: Bool) -> Void {
        let timestamp = videoPos * videoDuration
        let inferredVideoPos = Double(captions[selectedIndex].startTime) / videoDuration
        let inferredIndex = captions.firstIndex(where: { timestamp <= Double($0.endTime) }) ?? 0
        
        DispatchQueue.main.async {
            if isListControlling {
                NotificationCenter.default.post(name: .seekVideo, object: inferredVideoPos)
            }
            else if !isListControlling {
                NotificationCenter.default.post(name: .seekList, object: inferredIndex)
            }
        }
    }
    
    init(mode: Mode = .pause) {
        self.mode = mode
    }
}

var sampleCaptionData: [Caption] = load("captionDataLong")
