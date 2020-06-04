//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // Handle app state
    @EnvironmentObject var app: AppState
    
    // Scroll logic
    @State private var scrollOffset = CGPoint(x: 0.0, y: 0.0)
    @State private var scrollBinding: Binding<CGPoint> = .constant(.zero)
    let scrollAmount: CGFloat = 45.0
    let numCaptionsOnPage: Int = 12

    func turnPages(quantity numPages: Int) -> Void {
        scrollOffset.y += scrollAmount * CGFloat(numCaptionsOnPage * numPages)
    }
    
    func goToIndex(target: Int) {
        // Check if the target index is on a new page
        let distanceToNextPage = numCaptionsOnPage - (app.selectedIndex % numCaptionsOnPage)
        let distanceToPrevPage = distanceToNextPage - numCaptionsOnPage
        let delta = target - app.selectedIndex
        let isOnFuturePage: Bool = (delta >= distanceToNextPage)
        let isOnPrevPage: Bool = (delta < distanceToPrevPage)
        
        // Count the number of pages to turn
        var numPagesToTurn: Int {
            if delta > 0 && delta <= numCaptionsOnPage { return 1 }
            else if delta > numCaptionsOnPage { return delta / numCaptionsOnPage }
            else if delta < 0 && delta >= -numCaptionsOnPage { return -1 }
            else if delta < -numCaptionsOnPage { return delta / numCaptionsOnPage }
            else { return 0 }
        }
        
        // If applicable, turn to the relevant page
        if isOnFuturePage || isOnPrevPage {
            withAnimation { turnPages(quantity: numPagesToTurn) }
        }
        
        // Set the new selectedIndex
        app.selectedIndex = target
    }
    
    func incrementSelectedIndex() -> Void {
        // Guard against when last caption is selected
        guard app.selectedIndex < app.userData.count - 1 else { return }
        goToIndex(target: app.selectedIndex + 1)
    }
    
    func decrementSelectedIndex() -> Void {
        // Guard against when first caption is selected
        guard self.app.selectedIndex > 0 else { return }
        goToIndex(target: app.selectedIndex - 1)
    }
    
    func modifyTimeVal(byStepSize delta: Float) -> Void {
        if app.mode == .editStartTime {
            app.userData[app.selectedIndex].caption.startTime += delta
        } else if app.mode == .editEndTime {
            app.userData[app.selectedIndex].caption.endTime += delta
        }
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        app.userData[app.selectedIndex].caption.endTime += delta
    }
    
    func _addCaption() -> Void {
        app.userData = addCaption(toArray: app.userData, beforeIndex: app.selectedIndex, atTime: app.userData[app.selectedIndex].caption.startTime)
    }
    
    func _deleteCaption() -> Void {
        // Guard against only 1 caption remaining
        guard app.userData.count > 1 else { return }
        app.userData = deleteCaption(fromArray: app.userData, atIndex: app.selectedIndex)
        
        // If the last row is deleted, decrement app.selectedIndex
        if app.selectedIndex-1 == app.userData.count-1 {
            decrementSelectedIndex()
        }
    }
    
    func insertCharacter(_ char: String) -> Void {
        app.userData[app.selectedIndex].caption.text += char
    }
    
    func tag(withSymbol key: String) -> Void {
        let char = Character(key)
        
        if char.isLetter == true {
            self.app.userData[self.app.selectedIndex].style.symbol = key.uppercased()
            
            // Check if style already exists
            for style in app.styles {
                if style.symbol == key { return }
            }
            
            // If style does not exist, create a new style
            let newStyle = defaultStyle // TODO: Change this to save current style
            self.app.styles.append(newStyle)
        }
    }
    
    //init() {
    //    scrollBinding = scrollOffset as Binding<CGPoint>
    //}
    
    var body: some View {
        
        OffsetScrollView(.vertical, offset: $scrollOffset) {
        //ScrollView(.vertical) {
        //List {
            ForEach(app.userData) { data in
                Row(self.app, data)
                    .tag(data)
                    .padding(.vertical, 5)
                    //.offset(y: self.scrollOffset)
            }
        }
            
        //}
        //.content.offset(y: self.scrollOffset)
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            let key = notification.object as! String
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.tag(withSymbol: key)
            case .edit: self.insertCharacter(key)
            case .editStartTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.app.userData[self.app.selectedIndex].startTime)
                //strVal += String(describing: notification.object!)
                //self.app.userData[self.app.selectedIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.app.userData[self.app.selectedIndex].endTime)
                //strVal += String(describing: notification.object!)
                //self.app.userData[self.app.selectedIndex].endTime = (strVal as NSString).floatValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .edit: self.incrementSelectedIndex(); self.app.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .edit: self.decrementSelectedIndex(); self.app.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self._addCaption()
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .editStartTime, .editEndTime: self.app.transition(to: .edit)
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: ()
            case .edit: self.app.transition(to: .editStartTime)
            case .editStartTime: self.app.transition(to: .editEndTime)
            case .editEndTime: self.app.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause:
                if self.app.userData[self.app.selectedIndex].style.symbol != "" { self.app.userData[self.app.selectedIndex].style.symbol = "" }
                else { self._deleteCaption() }
            case .edit: _ = self.app.userData[self.app.selectedIndex].caption.text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.app.transition(to: .play)
            case .edit: self.insertCharacter(" ")
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.app.mode {
            case .play, .edit: self.app.transition(to: .pause)
            case .pause: ()
            case .editStartTime, .editEndTime: self.app.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .play)) { _ in
            DispatchQueue.global(qos: .background).async {
                while self.app.mode == .play {
                    self.app.syncVideoAndList(isListControlling: false)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .seekList)) { notification in
            let newIndex = notification.object as! Int
            
            // If the video playback has transitioned to the next caption
            if newIndex == self.app.selectedIndex + 1 {
                self.incrementSelectedIndex()
            }
                
            // If the video playback has not transitioned to the next caption
            else if newIndex == self.app.selectedIndex {}
            
            // If the video is seeking
            else {
                withAnimation { self.goToIndex(target: newIndex) }
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
