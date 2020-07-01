//
//  RowState.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import Combine
import SwiftUI

enum RowElement {
    case row, text, startTime, endTime
}

// The RowState struct stores the state of any individual row in the captions list
struct RowState {
    @EnvironmentObject var app: AppState
    
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
    //var app: AppState
    
    // The caption object for the current row
    var caption: Caption
    
    init(_ caption: Caption = Caption()) {
        //self.app = app
        self.caption = caption
    }
}
