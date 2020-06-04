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
    
    // The array of styled captions which is to be edited by the user
    @Published var userData: [StyledCaption] = sampleCaptionData
    
    // The array which stores captions as they return from the transcription API
    @Published var transcriptions: [Caption] = []
    
    // The array which stores various caption styles, editible by the user
    @Published var styles: [Style] = []
    
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
        let inferredVideoPos = Double(userData[selectedIndex].caption.startTime) / videoDuration
        let inferredIndex = userData.firstIndex(where: { timestamp <= Double($0.caption.endTime) }) ?? 0
        
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
