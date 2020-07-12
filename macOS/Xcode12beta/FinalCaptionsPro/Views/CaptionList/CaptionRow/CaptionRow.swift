//
//  CaptionRow.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

// Set state on mouse click event
func click(_ app: AppState, _ props: RowProperties, _ view: RowElement) -> Void {
    switch view {
    case .row:
        switch app.mode {
        case .play: app.transition(to: .pause)
        case .pause:
            if props.isSelected { app.transition(to: .edit) }
        case .edit: app.transition(to: .pause)
        case .editStartTime: app.transition(to: .pause)
        case .editEndTime: app.transition(to: .pause)
        }
    case .text:
        switch app.mode {
        case .play: app.transition(to: .pause)
        case .pause:
            if props.isSelected { app.transition(to: .edit) }
        case .edit: ()
        case .editStartTime: app.transition(to: .edit)
        case .editEndTime: app.transition(to: .edit)
        }
    case .startTime:
        switch app.mode {
        case .play: app.transition(to: .pause)
        case .pause:
            if props.isSelected { app.transition(to: .editStartTime) }
        case .edit: app.transition(to: .editStartTime)
        case .editStartTime: ()
        case .editEndTime: app.transition(to: .editStartTime)
        }
    case .endTime:
        switch app.mode {
        case .play: app.transition(to: .pause)
        case .pause:
            if props.isSelected { app.transition(to: .editEndTime) }
        case .edit: app.transition(to: .editEndTime)
        case .editStartTime: app.transition(to: .editEndTime)
        case .editEndTime: ()
        }
    }
    
    // Calling caption becomes selected
    app.selectedIndex = props.index
    
    // Update video player position
    app.isListControlling = true
        
    // Play video segment for better UX
    if app.mode == .edit {
        NotificationCenter.default.post(name: .playSegment, object: nil)
    }
}

// ViewModifier allows each subview to be clicked once or twice (when appropriate)
struct Clickable: ViewModifier {
    var app: AppState
    var props: RowProperties
    var view: RowElement
    
    init(_ app: AppState, _ props: RowProperties, _ view: RowElement) {
        self.app = app
        self.props = props
        self.view = view
    }
    
    func body(content: Content) -> some View {
        content
        .onTapGesture(count: props.clickNumber) {
            click(app, props, view)
        }
        .onTapGesture(count: 1) {
            click(app, props, view)
        }
    }
}

// Custom modifier to make a subview clickable
extension View {
    func clickable(_ app: AppState, _ props: RowProperties, fromView view: RowElement) -> some View {
        self.modifier(Clickable(app, props, view))
    }
}

// Row properties as an object
class RowProperties: ObservableObject {
    var caption: Caption
    var index: Int
    var isSelected: Bool
    var clickNumber: Int
    var color: Color
    
    init(_ caption: Caption, _ index: Int, _ isSelected: Bool, _ clickNumber: Int, _ color: Color) {
        self.caption = caption
        self.index = index
        self.isSelected = isSelected
        self.clickNumber = clickNumber
        self.color = color
    }
}

// Various clickable elements of the row
enum RowElement {
    case row, text, startTime, endTime
}

struct CaptionRow: View {
    
    // Constants
    let scrollbarPadding = CGFloat(20.0)
    
    // Variables
    @EnvironmentObject var app: AppState
    var caption: Caption
    
    var props: RowProperties {
        // The caption object itself
        var caption: Caption {
            return self.caption
        }
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
        return RowProperties(caption, index, isSelected, clickNumber, color)
    }
        
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(props.color).frame(height: 40)
                .clickable(app, props, fromView: .row)
            HStack {
                if props.isSelected {
                    Timings()
                    RepeatButton()
                    Spacer()
                    TextView()
                    Spacer()
                    Tag()
                    PlusMinus()
                }
                else if !props.isSelected {
                    Timings()
                    Spacer()
                    TextView()
                    Spacer()
                    Tag()
                }
            }
            .padding(.trailing, scrollbarPadding)
        }
        .frame(height: 30)
        .environmentObject(props)
    }
}

struct CaptionRow_Previews: PreviewProvider {
    
    static var playState = AppState(mode: .play)
    static var pauseState = AppState(mode: .pause)
    static var editState = AppState(mode: .edit)
    static var editStart = AppState(mode: .editStartTime)
    static var editEnd = AppState(mode: .editEndTime)
    static var nonSelect = AppState()
    static var index: Int = 0

    static var previews: some View {
        
        VStack(spacing: 40) {
            Spacer()
            CaptionRow(caption: Caption(text: "Mary had a little lamb"))
                .environmentObject(playState)
            CaptionRow(caption: Caption(text: "Mary had a little lamb"))
                .environmentObject(pauseState)
            CaptionRow(caption: Caption(id: 1, text: "Mary had a little lamb"))
                .environmentObject(nonSelect)
            CaptionRow(caption: Caption(text: "testing"))
                .environmentObject(editState)
            CaptionRow(caption: Caption(text: "Mary had a little lamb"))
                .environmentObject(editStart)
            CaptionRow(caption: Caption(text: "Mary had a little lamb"))
                .environmentObject(editEnd)
            Spacer()
        }
        .frame(width: 1600/3)  // from ContentView
        .environmentObject(RowProperties(Caption(), 0, true, 1, .black))
    }
}
