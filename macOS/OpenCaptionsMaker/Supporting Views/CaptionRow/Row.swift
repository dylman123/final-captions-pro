//
//  Row.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

enum RowElement {
    case row, text, startTime, endTime
}

class RowState: ObservableObject {
    
    // To index the current row
    var index: Int {
        return app.userData.firstIndex(where: { $0.id == data.id }) ?? 0
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
    
    // App state
    var app: AppState
    
    // The styled caption data object for the current row
    var data: StyledCaption
    
    init(_ app: AppState = AppState(), _ data: StyledCaption = StyledCaption()) {
        self.app = app
        self.data = data
    }
}

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
    private var data: StyledCaption  // The caption object in the current row
    private var isSelected: Bool  // Is the current row selected?
    private var index: Int  // The current row's index in the list
    private var clickNumber: Int  // An integer to define clicking behaviour
    private var color: Color  // The current row's colour
    
    init(_ app: AppState, _ styledCaption: StyledCaption) {
        // RowState cannot inherent app from the environment, needs to be passed in as an argument.
        self.row = RowState(app, styledCaption)
        self.data = row.data
        self.isSelected = row.isSelected
        self.index = row.index
        self.clickNumber = row.clickNumber
        self.color = row.color
    }
        
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color).frame(height: 40).clickable(row, fromView: .row)
            Tag()
            HStack(alignment: .center) {
                if isSelected {
                    Timings()
                    Spacer()
                    TextView()
                    Spacer()
                    PlusMinus()
                }
                else if !row.isSelected {
                    Timings()
                    Spacer()
                    TextView()
                    Spacer()
                }
            }
            .padding(.trailing, scrollbarPadding)
        }
        .frame(height: 30)
        .environmentObject(row)
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
            Row(playState, playState.userData[index])
                .environmentObject(playState)
            Row(pauseState, pauseState.userData[index])
                .environmentObject(pauseState)
            Row(editState, editState.userData[index])
                .environmentObject(editState)
            Row(editState, editState.userData[index+1])
                .environmentObject(editState)
            Spacer()
        }
    }
}
