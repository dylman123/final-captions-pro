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
                case .pause: if isSelected { self.state.mode = .edit }
                case .edit: self.state.mode = .editStartTime
                case .editStartTime: ()
                case .editEndTime: self.state.mode = .editStartTime
            }
        case .endTime:
            switch state.mode {
                case .play: self.state.mode = .pause
                case .pause: if isSelected { self.state.mode = .edit }
                case .edit: self.state.mode = .editEndTime
                case .editStartTime: self.state.mode = .editEndTime
                case .editEndTime: ()
            }
        }
        self.state.selectionIndex = self.captionIndex
    }
    
    var body: some View {
        
        ZStack {
            
            // Row background
            RoundedRectangle(cornerRadius: 10).fill(rowColor)
                .frame(height: 40)
                .onTapGesture { self.setStateOnTap(fromView: .row) }
            
            // Caption contents
            HStack(alignment: .center) {
                
                // Display caption timings
                VStack {
                    if (state.mode == .edit || state.mode == .editStartTime || state.mode == .editEndTime) && isSelected {
                        Stepper(value: captionBinding.startTime, step: -0.1) {
                            ZStack {
                                Text(String(format: "%.1f", caption.startTime))
                                    .onTapGesture { self.setStateOnTap(fromView: .startTime) }
                                if state.mode == .editStartTime {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .strokeBorder(Color.white, lineWidth: 2)
                                    )
                                }
                            }
                            .padding(.leading)
                        }
                        Spacer()
                        Stepper(value: captionBinding.endTime, step: -0.1) {
                            ZStack {
                                Text(String(format: "%.1f", caption.endTime))
                                    .onTapGesture { self.setStateOnTap(fromView: .endTime) }
                                if state.mode == .editEndTime {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .strokeBorder(Color.white, lineWidth: 2)
                                    )
                                }
                            }
                            .padding(.leading)
                        }
                    } else {
                        Text(String(format: "%.1f", caption.startTime))
                            .onTapGesture {
                                self.setStateOnTap(fromView: .startTime)
                            }
                        Spacer()
                        Text(String(format: "%.1f", caption.endTime))
                            .onTapGesture {
                                self.setStateOnTap(fromView: .endTime)
                            }
                    }
                }
                .frame(width: 80.0)
                
                Spacer()
                
                ZStack {
                    Text(caption.text)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(width: 300)
                        .offset(x: -30)
                        .onTapGesture {
                            self.setStateOnTap(fromView: .text)
                        }
                    if state.mode == .edit && isSelected {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.clear)
                            .frame(width: 300, height: 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(Color.white, lineWidth: 2)
                        )
                    }
                }
                
                Spacer()
                
                // Display insert plus and minus icons
                VStack {
                    
                    if isSelected {
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
                    } else {
                        Spacer()
                    }
                }
                .buttonStyle(buttonStyle)
                .padding(.trailing)
            }
        }
        .frame(height: 30)
    }
}

struct CaptionRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionRow(caption: userData.captions[0])
            .frame(height: 100)
    }
}
