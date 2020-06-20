//
//  Row.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

// Set state on mouse click event
func click(row: RowState, view: RowElement) -> Void {
    let state = row.app
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
    var view: RowElement
    
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
    func clickable(_ row: RowState, fromView view: RowElement) -> some View {
        self.modifier(Clickable(row: row, view: view))
    }
}

struct Row: View {
    
    // Constants
    let scrollbarPadding = CGFloat(20.0)
    
    // Variables
    @EnvironmentObject var app: AppState
    private var row: RowState  // An object to hold the state of the current row
    
    init(_ app: AppState, _ caption: Caption) {
        // RowState cannot inherent app from the environment, needs to be passed in as an argument.
        self.row = RowState(app, caption)
    }
        
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(row.color).frame(height: 40).clickable(row, fromView: .row)
            Tag(row)
            HStack(alignment: .center) {
                if row.isSelected {
                    Timings(row)
                    Spacer()
                    TextView(row)
                    Spacer()
                    PlusMinus(row)
                }
                else if !row.isSelected {
                    Timings(row)
                    Spacer()
                    TextView(row)
                    Spacer()
                }
            }
            .padding(.trailing, scrollbarPadding)
        }
        .frame(height: 30)
    }
}

struct Row_Previews: PreviewProvider {
    
    static var playState = AppState(mode: .play)
    static var pauseState = AppState(mode: .pause)
    static var editState = AppState(mode: .edit)
    static var index: Int = 0

    static var previews: some View {
        
        VStack(spacing: 40) {
            Spacer()
            Row(playState, playState.captions[index])
                .environmentObject(playState)
            Row(pauseState, pauseState.captions[index])
                .environmentObject(pauseState)
            Row(editState, editState.captions[index])
                .environmentObject(editState)
            Row(editState, editState.captions[index+1])
                .environmentObject(editState)
            Spacer()
        }
    }
}
