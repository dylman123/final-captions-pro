//
//  AppState.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import Combine
import SwiftUI

enum Mode {
    case play, pause, edit, editStartTime, editEndTime
}

// The AppState class stores the state of the entire app
class AppState: ObservableObject {
    
    // The array of captions which is to be edited by the user
    @Published var captions: [Caption] = []
    //@Published var captions: [Caption] = sampleCaptionData
    
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
    @Published var videoURL: URL?
    //@Published var videoURL = Bundle.main.url(forResource: "RAW-long", withExtension: "m4v")
    
    // To control whether the list controls video or vice versa
    @Published var isListControlling: Bool = false
    
    // Set state within the application
    func transition(to newState: Mode) -> Void {
        mode = newState
        let notification = NSNotification.Name(String(describing: newState))
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    init(mode: Mode = .pause) {
        self.mode = mode
    }
}
