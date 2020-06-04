//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // Handle state
    @EnvironmentObject var state: AppState
    
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
        let distanceToNextPage = numCaptionsOnPage - (state.selectedIndex % numCaptionsOnPage)
        let distanceToPrevPage = distanceToNextPage - numCaptionsOnPage
        let delta = target - state.selectedIndex
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
        state.selectedIndex = target
    }
    
    func incrementSelectedIndex() -> Void {
        // Guard against when last caption is selected
        guard state.selectedIndex < state.captions.count - 1 else { return }
        goToIndex(target: state.selectedIndex + 1)
    }
    
    func decrementSelectedIndex() -> Void {
        // Guard against when first caption is selected
        guard self.state.selectedIndex > 0 else { return }
        goToIndex(target: state.selectedIndex - 1)
    }
    
    func modifyTimeVal(byStepSize delta: Float) -> Void {
        if state.mode == .editStartTime {
            state.captions[state.selectedIndex].startTime += delta
        } else if state.mode == .editEndTime {
            state.captions[state.selectedIndex].endTime += delta
        }
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        state.captions[state.selectedIndex].endTime += delta
    }
    
    func _addCaption() -> Void {
        state.captions = addCaption(toArray: state.captions, beforeIndex: state.selectedIndex, atTime: state.captions[state.selectedIndex].startTime)
    }
    
    func _deleteCaption() -> Void {
        // Guard against only 1 caption remaining
        guard state.captions.count > 1 else { return }
        state.captions = deleteCaption(fromArray: state.captions, atIndex: state.selectedIndex)
        
        // If the last row is deleted, decrement selection
        if state.selectedIndex-1 == state.captions.count-1 {
            decrementSelectedIndex()
        }
    }
    
    func insertCharacter(_ char: String) -> Void {
        state.captions[state.selectedIndex].text += char
    }
    
    //init() {
    //    scrollBinding = scrollOffset as Binding<CGPoint>
    //}
    
    var body: some View {
        
        OffsetScrollView(.vertical, offset: $scrollOffset) {
        //ScrollView(.vertical) {
        //List {
            ForEach(state.captions) { caption in
                Row(self.state, caption)
                    .tag(caption)
                    .padding(.vertical, 5)
                    //.offset(y: self.scrollOffset)
            }
        }
            
        //}
        //.content.offset(y: self.scrollOffset)
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            let char = notification.object as! String
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: self.state.captions[self.state.selectedIndex].tag = char.uppercased()
            case .edit: self.insertCharacter(char)
            case .editStartTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.state.captions[self.state.selectedIndex].startTime)
                //strVal += String(describing: notification.object!)
                //self.state.captions[self.state.selectedIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.state.captions[self.state.selectedIndex].endTime)
                //strVal += String(describing: notification.object!)
                //self.state.captions[self.state.selectedIndex].endTime = (strVal as NSString).floatValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause, .edit: self.incrementSelectedIndex(); self.state.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause, .edit: self.decrementSelectedIndex(); self.state.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: self._addCaption()
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause, .editStartTime, .editEndTime: self.state.transition(to: .edit)
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: ()
            case .edit: self.state.transition(to: .editStartTime)
            case .editStartTime: self.state.transition(to: .editEndTime)
            case .editEndTime: self.state.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause:
                if self.state.captions[self.state.selectedIndex].tag != "" { self.state.captions[self.state.selectedIndex].tag = "" }
                else { self._deleteCaption() }
            case .edit: _ = self.state.captions[self.state.selectedIndex].text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: self.state.transition(to: .play)
            case .edit: self.insertCharacter(" ")
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.state.mode {
            case .play, .edit: self.state.transition(to: .pause)
            case .pause: ()
            case .editStartTime, .editEndTime: self.state.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .play)) { _ in
            DispatchQueue.global(qos: .background).async {
                while self.state.mode == .play {
                    self.state.syncVideoAndList(isListControlling: false)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .seekList)) { notification in
            let newIndex = notification.object as! Int
            
            // If the video playback has transitioned to the next caption
            if newIndex == self.state.selectedIndex + 1 {
                self.incrementSelectedIndex()
            }
                
            // If the video playback has not transitioned to the next caption
            else if newIndex == self.state.selectedIndex {}
            
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
