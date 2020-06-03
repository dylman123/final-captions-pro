//
//  CaptionRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionRow: View {
    
    // Handle state
    @EnvironmentObject var state: AppState
    
    // The current caption binding
    var captionBinding: Binding<Caption> {
        return $state.captions[captionIndex]
    }
    
    // Logic to select caption
    var isSelected: Bool {
        if state.selectedIndex == captionIndex { return true }
        else { return false }
    }
        
    // Display caption color
    var rowColor: Color {
        if isSelected {
            switch state.mode {
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
    
    // The current caption object
    var caption: Caption
    
    // To index the current caption
    var captionIndex: Int {
        return state.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
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
    
    enum CaptionElement {
        case row, text, startTime, endTime
    }
    
    // Select single or double click
    var clickNumber: Int {
        if isSelected { return 2 }
        else { return 1 }
    }
    
    // Set state on mouse click event
    func click(fromView view: CaptionElement) -> Void {
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
            RoundedRectangle(cornerRadius: 10).fill(rowColor)
                .frame(height: 40)
                .onTapGesture(count: self.clickNumber) { self.click(fromView: .row) }
                .onTapGesture(count: 1) { self.click(fromView: .row) }
            
            // Style tag
            if caption.tag != "" || (isSelected && state.mode != .play) {
                Tag(caption.tag)
                    .offset(x: 180)
                    .onTapGesture(count: self.clickNumber) { self.click(fromView: .row) }
                    .onTapGesture(count: 1) { self.click(fromView: .row) }
            }
            
            // Caption contents
            HStack(alignment: .center) {
                
                if isSelected {
                    // Display caption timings
                    VStack {
                        
                        // Start Time
                        if state.mode == .editStartTime {
                            Stepper(value: captionBinding.startTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.startTime))
                                        .onTapGesture(count: self.clickNumber) { self.click(fromView: .startTime) }
                                        .onTapGesture(count: 1) { self.click(fromView: .startTime) }
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.startTime))
                                .onTapGesture(count: self.clickNumber) { self.click(fromView: .startTime) }
                                .onTapGesture(count: 1) { self.click(fromView: .startTime) }
                        }
                        Spacer()
                        
                        // End Time
                        if state.mode == .editEndTime {
                            Stepper(value: captionBinding.endTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.endTime))
                                        .onTapGesture(count: self.clickNumber) { self.click(fromView: .endTime) }
                                        .onTapGesture(count: 1) { self.click(fromView: .endTime) }
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.endTime))
                                .onTapGesture(count: self.clickNumber) { self.click(fromView: .endTime) }
                                .onTapGesture(count: 1) { self.click(fromView: .endTime) }
                        }
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    
                    // Caption text
                    ZStack {
                        if state.mode == .play {
                            Text(caption.text).offset(x: -5)
                        } else if state.mode == .edit {
                            Text(caption.text + "|").offset(x: 2)  // TODO: Make cursor blink
                            SelectionBox()
                        } else { Text(caption.text) }
                    }
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .onTapGesture(count: self.clickNumber) { self.click(fromView: .text) }
                    .onTapGesture(count: 1) { self.click(fromView: .text) }
                    .offset(x: textOffset + deltaOffset)
                    .frame(width: textWidth)
                    Spacer()
                    
                    VStack {
                        // Plus button
                        Button(action: {
                            self.state.captions = addCaption(toArray: self.state.captions, beforeIndex: self.captionIndex, atTime: self.caption.startTime)
                        }) { if state.mode != .play {  // Don't show +- buttons in play mode
                            IconView("NSAddTemplate")
                                .frame(width: 12, height: 12)
                            }
                        }
                        
                        // Minus button
                        Button(action: {
                            self.state.captions = deleteCaption(fromArray: self.state.captions, atIndex: self.captionIndex)
                        }) {
                            if (state.mode != .play) && (state.captions.count > 1) {  // Don't give option to delete when only 1 caption is in list
                                IconView("NSRemoveTemplate")
                                .frame(width: 12, height: 12)
                            }
                        }
                    }
                    .buttonStyle(buttonStyle)
                    
                } else if !isSelected {
                    
                    // Display caption timings
                    VStack {
                        Text(String(format: "%.1f", caption.startTime))
                            .onTapGesture(count: self.clickNumber) { self.click(fromView: .startTime) }
                            .onTapGesture(count: 1) { self.click(fromView: .startTime) }
                        Spacer()
                        Text(String(format: "%.1f", caption.endTime))
                           .onTapGesture(count: self.clickNumber) { self.click(fromView: .endTime) }
                            .onTapGesture(count: 1) { self.click(fromView: .endTime) }
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    
                    // Display caption text
                    Text(caption.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: textWidth)
                        .offset(x: textOffset)
                        .onTapGesture(count: self.clickNumber) { self.click(fromView: .text) }
                        .onTapGesture(count: 1) { self.click(fromView: .text) }
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
            CaptionRow(caption: playState.captions[index])
                .environmentObject(playState)
            CaptionRow(caption: pauseState.captions[index])
                .environmentObject(pauseState)
            CaptionRow(caption: editState.captions[index])
                .environmentObject(editState)
            CaptionRow(caption: editState.captions[index+1])
                .environmentObject(editState)
            Spacer()
        }
    }
}
