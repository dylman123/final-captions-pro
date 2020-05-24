//
//  CaptionRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionRow: View {
    
    // To refresh the UI when userData changes
    @EnvironmentObject var userDataEnvObj: UserData
    
    // To manage Mode state
    @EnvironmentObject var state: CaptionListState
    
    // The current caption binding
    var captionBinding: Binding<Caption> {
        return $userDataEnvObj.captions[captionIndex]
    }
    
    // Logic to select caption
    var isSelected: Bool {
        if state.selectionIndex == captionIndex { return true }
        else { return false }
    }
        
    // Display caption color
    var rowColor: Color {
        if isSelected {
            if state.mode == .edit || state.mode == .editStartTime || state.mode == .editEndTime {
                return Color.gray.opacity(0.5)
            } else { return Color.yellow.opacity(0.5) }
        }
        else {
            return Color.black.opacity(0.5)
        }
    }
    
    // The current caption object
    var caption: Caption
    
    // To index the current caption
    var captionIndex: Int {
        return userData.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
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
    
    // Handle mouse clicks
    func setStateOnTap(fromView view: CaptionElement) -> Void {
        switch view {
        case .row:
            switch state.mode {
                case .play: self.state.mode = .pause
                case .pause: if isSelected { self.state.mode = .edit }
                case .edit: self.state.mode = .pause
                case .editStartTime: self.state.mode = .pause
                case .editEndTime: self.state.mode = .pause
            }
        case .text:
            switch state.mode {
                case .play: self.state.mode = .pause
                case .pause: if isSelected { self.state.mode = .edit }
                case .edit: self.state.mode = .pause
                case .editStartTime: self.state.mode = .edit
                case .editEndTime: self.state.mode = .edit
            }
        case .startTime:
            switch state.mode {
                case .play: self.state.mode = .pause
                case .pause: if isSelected { self.state.mode = .editStartTime }
                case .edit: self.state.mode = .editStartTime
                case .editStartTime: ()
                case .editEndTime: self.state.mode = .editStartTime
            }
        case .endTime:
            switch state.mode {
                case .play: self.state.mode = .pause
                case .pause: if isSelected { self.state.mode = .editEndTime }
                case .edit: self.state.mode = .editEndTime
                case .editStartTime: self.state.mode = .editEndTime
                case .editEndTime: ()
            }
        }
        self.state.selectionIndex = self.captionIndex
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
                .onTapGesture { self.setStateOnTap(fromView: .row) }
                
            // Caption contents
            HStack(alignment: .center) {
                
                if isSelected {
                    // Display caption timings
                    VStack {
                        if self.state.mode == .editStartTime {
                            Stepper(value: captionBinding.startTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.startTime))
                                        .onTapGesture { self.setStateOnTap(fromView: .startTime) }
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.startTime))
                                .onTapGesture { self.setStateOnTap(fromView: .startTime) }
                        }
                        Spacer()
                        if self.state.mode == .editEndTime {
                            Stepper(value: captionBinding.endTime, step: -0.1) {
                                ZStack {
                                    Text(String(format: "%.1f", caption.endTime))
                                        .onTapGesture { self.setStateOnTap(fromView: .endTime) }
                                    SelectionBox()
                                }
                            }
                            .padding(.leading, timePadding)
                        } else {
                            Text(String(format: "%.1f", caption.endTime))
                                .onTapGesture { self.setStateOnTap(fromView: .endTime) }
                        }
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    // Display caption text
                    ZStack {
                        Text(caption.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .onTapGesture { self.setStateOnTap(fromView: .text) }
                        if self.state.mode == .edit { SelectionBox() }
                    }
                    .offset(x: textOffset + deltaOffset)
                    .frame(width: textWidth)
                    Spacer()
                    VStack {
                        Button(action: {
                            addCaption(beforeIndex: self.captionIndex, atTime: self.caption.startTime)
                        }) {
                            IconView("NSAddTemplate")
                                .frame(width: 12, height: 12)
                        }
                        Button(action: {
                            deleteCaption(atIndex: self.captionIndex)
                        }) {
                            if userData.captions.count > 1 {  // Don't give option to delete when only 1 caption is in list
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
                            .onTapGesture { self.setStateOnTap(fromView: .startTime) }
                        Spacer()
                        Text(String(format: "%.1f", caption.endTime))
                           .onTapGesture { self.setStateOnTap(fromView: .endTime) }
                    }
                    .frame(width: timeWidth)
                    Spacer()
                    // Display caption text
                    Text(caption.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: textWidth)
                        .offset(x: textOffset)
                        .onTapGesture { self.setStateOnTap(fromView: .text) }
                    Spacer()
                }
            }
            .padding(.trailing, scrollbarPadding)
        }
        .frame(height: 30)
    }
}

//var test = CaptionListState()
struct CaptionRow_Previews: PreviewProvider {

    static var previews: some View {
        CaptionRow(caption: userData.captions[0])
            .frame(height: 100)
            //.environmentObject(test)
    }
}
