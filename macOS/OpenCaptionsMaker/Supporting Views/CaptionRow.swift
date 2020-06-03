//
//  CaptionRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

enum CaptionElement {
    case row, text, startTime, endTime
}

struct RowState {
    
    // To index the current row
    var index: Int {
        return appState.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
    }
    
    // Logic to select caption
    var isSelected: Bool {
        if appState.selectedIndex == index { return true }
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
            switch appState.mode {
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
    
    // App state
    var appState: AppState
    
    // The caption object for the current row
    var caption: Caption
    
    init(_ appState: AppState, _ caption: Caption) {
        self.appState = appState
        self.caption = caption
    }
}

// Set state on mouse click event
func click(row: RowState, view: CaptionElement) -> Void {
    let state = row.appState
    let isSelected = row.isSelected
    let captionIndex = row.index
    switch view {
    case .row:
        switch state.mode {
        case .play: state.transition(to: .pause)
        case .pause: if isSelected { state.transition(to: .edit) }
        case .edit: state.transition(to: .pause)
        case .editStartTime: state.transition(to: .pause)
        case .editEndTime: state.transition(to: .pause)
        }
    case .text:
        switch state.mode {
        case .play: state.transition(to: .pause)
        case .pause: if isSelected { state.transition(to: .edit) }
        case .edit: state.transition(to: .pause)
        case .editStartTime: state.transition(to: .edit)
        case .editEndTime: state.transition(to: .edit)
        }
    case .startTime:
        switch state.mode {
        case .play: state.transition(to: .pause)
        case .pause: if isSelected { state.transition(to: .editStartTime) }
        case .edit: state.transition(to: .editStartTime)
        case .editStartTime: ()
        case .editEndTime: state.transition(to: .editStartTime)
        }
    case .endTime:
        switch state.mode {
        case .play: state.transition(to: .pause)
        case .pause: if isSelected { state.transition(to: .editEndTime) }
        case .edit: state.transition(to: .editEndTime)
        case .editStartTime: state.transition(to: .editEndTime)
        case .editEndTime: ()
        }
    }
    state.selectedIndex = captionIndex  // Calling caption becomes selected
    state.syncVideoAndList(isListControlling: true)
}

// ViewModifier allows each subview to be clicked once or twice (when appropriate)
struct Clickable: ViewModifier {
    var row: RowState
    var view: CaptionElement
    
    func body(content: Content) -> some View {
        content
        .onTapGesture(count: row.clickNumber) {
                click(row: self.row, view: self.view)
        }
        .onTapGesture(count: 1) {
            click(row: self.row, view: self.view)
        }
    }
}

// Custom modifier to make a subview clickable
extension View {
    func clickable(_ row: RowState, fromView view: CaptionElement) -> some View {
        self.modifier(Clickable(row: row, view: view))
    }
}

// Draw a box when element is selected
struct SelectionBox: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.white, lineWidth: 2)
            )
    }
}

struct CaptionRow: View {
    
    // Handle state
    @EnvironmentObject var appState: AppState
    private var row: RowState  // An object to hold the state of the current row
    private var caption: Caption  // The caption object in the current row
    private var isSelected: Bool  // Is the current row selected?
    private var index: Int  // The current row's index in the list
    private var clickNumber: Int  // An integer to define clicking behaviour
    private var color: Color  // The current row's colour

    // The current caption binding
    var binding: Binding<Caption> {
        return $appState.captions[index]
    }
    
    init(_ appState: AppState, _ caption: Caption) {
        // RowState cannot inherent appState from the environment, needs to be passed in as an argument.
        self.row = RowState(appState, caption)
        self.caption = row.caption
        self.isSelected = row.isSelected
        self.index = row.index
        self.clickNumber = row.clickNumber
        self.color = row.color
    }
    
    // To format the time values in text
    var timeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    // To format the plus button
    var buttonStyle = BorderlessButtonStyle()
    
    // Geometric variables for even spacing
    // Caption timing values
    let timeWidth = CGFloat(100.0)
    let timePadding = CGFloat(20.0)
    // Caption Text
    let textWidth = CGFloat(300.0)
    let textOffset = CGFloat(-40.0)
    let deltaOffset = CGFloat(6.0)
    // Scrollbar
    let scrollbarPadding = CGFloat(20.0)
        
    var body: some View {
        
        ZStack {
        
            // Row background
            RoundedRectangle(cornerRadius: 10).fill(color)
                .frame(height: 40)
                .clickable(row, fromView: .row)
            
            // Style tag
            Tag(row).clickable(row, fromView: .row)
            
            // Caption contents
            HStack(alignment: .center) {
                
                if isSelected {
                    // Display caption timings
                    VStack {
                        
                        // Start Time
                        if appState.mode == .editStartTime {
                            Stepper(value: binding.startTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.startTime))
                                        .clickable(row, fromView: .startTime)
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.startTime))
                                .clickable(row, fromView: .startTime)
                        }
                        Spacer()
                        
                        // End Time
                        if appState.mode == .editEndTime {
                            Stepper(value: binding.endTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.endTime))
                                        .clickable(row, fromView: .endTime)
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.endTime))
                                .clickable(row, fromView: .endTime)
                        }
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    
                    // Caption text
                    ZStack {
                        if appState.mode == .play {
                            Text(caption.text).offset(x: -5)
                        } else if appState.mode == .edit {
                            Text(caption.text + "|").offset(x: 2)  // TODO: Make cursor blink
                            SelectionBox()
                        } else { Text(caption.text) }
                    }
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .clickable(row, fromView: .text)
                    .offset(x: textOffset + deltaOffset)
                    .frame(width: textWidth)
                    Spacer()
                    
                    VStack {
                        // Plus button
                        Button(action: {
                            self.appState.captions = addCaption(toArray: self.appState.captions, beforeIndex: self.index, atTime: self.caption.startTime)
                        }) { if appState.mode != .play {  // Don't show +- buttons in play mode
                            IconView("NSAddTemplate")
                                .frame(width: 12, height: 12)
                            }
                        }
                        
                        // Minus button
                        Button(action: {
                            self.appState.captions = deleteCaption(fromArray: self.appState.captions, atIndex: self.index)
                        }) {
                            if (appState.mode != .play) && (appState.captions.count > 1) {  // Don't give option to delete when only 1 caption is in list
                                IconView("NSRemoveTemplate")
                                .frame(width: 12, height: 12)
                            }
                        }
                    }
                    .buttonStyle(buttonStyle)
                    
                } else if !row.isSelected {
                    
                    // Display caption timings
                    VStack {
                        Text(String(format: "%.1f", caption.startTime))
                            .clickable(row, fromView: .startTime)
                        Spacer()
                        Text(String(format: "%.1f", caption.endTime))
                           .clickable(row, fromView: .endTime)
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    
                    // Display caption text
                    Text(caption.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: textWidth)
                        .offset(x: textOffset)
                        .clickable(row, fromView: .text)
                    Spacer()
                }
            }
            .padding(.trailing, scrollbarPadding)
        }
        .frame(height: 30)
    }
}

struct CaptionRow_Previews: PreviewProvider {
    
    static var playState = AppState(mode: .play)
    static var pauseState = AppState(mode: .pause)
    static var editState = AppState(mode: .edit)
    static var index: Int = 0

    static var previews: some View {
        
        VStack(spacing: 40) {
            Spacer()
            CaptionRow(playState, playState.captions[index])
                .environmentObject(playState)
            CaptionRow(pauseState, pauseState.captions[index])
                .environmentObject(pauseState)
            CaptionRow(editState, editState.captions[index])
                .environmentObject(editState)
            CaptionRow(editState, editState.captions[index+1])
                .environmentObject(editState)
            Spacer()
        }
    }
}
