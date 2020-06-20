//
//  State.swift
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

// The AppState class stores the state of the entire app
class AppState: ObservableObject {
    
    // The array of captions which is to be edited by the user
    @Published var captions: [Caption] = sampleCaptionData
    
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
    
    // Set state within the application
    func transition(to newState: Mode) -> Void {
        mode = newState
        let notification = NSNotification.Name(String(describing: newState))
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    // Sync video playback with list index
    func syncVideoAndList(isListControlling: Bool) -> Void {
        let timestamp = videoPos * videoDuration
        let inferredVideoPos = Double(captions[selectedIndex].start) / videoDuration
        let inferredIndex = captions.firstIndex(where: { timestamp <= Double($0.end) }) ?? 0
        
        DispatchQueue.main.async {
            if isListControlling {
                NotificationCenter.default.post(name: .seekVideo, object: inferredVideoPos)
            }
            else if !isListControlling {
                NotificationCenter.default.post(name: .seekList, object: inferredIndex)
            }
            publishToVisualOverlay(animate: false)
        }
    }
    
    init(mode: Mode = .pause) {
        self.mode = mode
    }
}

enum RowElement {
    case row, text, startTime, endTime
}

// The RowState struct stores the state of any individual row in the captions list
struct RowState {
    
    // To index the current row
    var index: Int {
        return app.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
    }
    
    // Logic to select caption
    var isSelected: Bool {
        if app.selectedIndex == index { return true }
        else { return false }
    }
    
    // To track whether user can do a double click
    var clickNumber: Int {
        if isSelected { return 2 }
        else { return 1 }
    }
    
    // Display caption color
    var color: Color {
        if isSelected {
            switch app.mode {
            case .play: return Color.blue.opacity(0.5)
            case .pause: return Color.gray.opacity(0.5)
            case .edit: return Color.yellow.opacity(0.5)
            case .editStartTime: return Color.yellow.opacity(0.5)
            case .editEndTime: return Color.yellow.opacity(0.5)
            }
        }
        else {
            return Color.black.opacity(0.5)
        }
    }
    
    // The AppState object, passed in via the initializer
    var app: AppState
    
    // The caption object for the current row
    var caption: Caption
    
    init(_ app: AppState = AppState(), _ caption: Caption = Caption()) {
        self.app = app
        self.caption = caption
    }
}
