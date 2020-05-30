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
    
    // Selected caption's index for the list
    /*var state.selectedIndex: ObservableObject {
        if state.mode == .play {
            return findIndexFromTimestamp()
        } else {
            return state.selectedIndex
        }
    }*/
    
    func findIndexFromTimestamp() -> Int {
        let timestamp = state.videoPos * state.videoDuration
        let index = state.captions.firstIndex(where: { timestamp <= Double($0.endTime) }) ?? 0
        return index
    }
    
    // Scroll logic
    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollBinding: Binding<CGPoint> = .constant(.zero)
    let scrollAmount: CGFloat = 45.0
    let scrollTrigger: Int = 11
    
    private var isAtPageEnd: Bool {
        let index = state.selectedIndex
        guard index > 0 else { return false }
        if index % scrollTrigger == 0 { return true }
        else { return false }
    }

    func animateOnCondition(_ condition: Bool, indexOperation: () -> (), scrollOperation: () -> ()) {
        if condition { withAnimation { indexOperation(); scrollOperation() } }
        else { indexOperation() }
    }
    
    func modifyTimeVal(byStepSize delta: Float) -> Void {
        if state.mode == .editStartTime {
            state.captions[state.selectedIndex].startTime += delta
        } else if state.mode == .editEndTime {
            state.captions[state.selectedIndex].endTime += delta
        }
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        self.state.captions[self.state.selectedIndex].endTime += delta
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
            decrementSelectionIndex()
        }
    }
    
    func insertCharacter(_ char: String) -> Void {
        state.captions[state.selectedIndex].text += char
    }
    
    func incrementSelectionIndex() -> Void {
        // Guard against when last caption is selected
        guard self.state.selectedIndex < self.state.captions.count - 1 else { return }
        
        self.animateOnCondition(self.isAtPageEnd,
        indexOperation: { state.selectedIndex += 1 },
        scrollOperation: { self.scrollOffset -= self.scrollAmount * CGFloat(self.scrollTrigger) })
    }
    
    func decrementSelectionIndex() -> Void {
        // Guard against when first caption is selected
        guard self.state.selectedIndex > 0 else { return }
        
        self.animateOnCondition(self.isAtPageEnd,
        indexOperation: { state.selectedIndex -= 1 },
        scrollOperation: { self.scrollOffset += self.scrollAmount * CGFloat(self.scrollTrigger) })
    }
    
    //init() {
    //    scrollBinding = scrollOffset as Binding<CGPoint>
    //}
    
    var body: some View {
        
        //OffsetScrollView(.vertical, offset: self.scrollBinding)
        ScrollView(.vertical) {
            VStack {
                ForEach(state.captions) { caption in
                    CaptionRow(caption: caption)
                        .tag(caption)
                        .padding(.vertical, 5)
                }
            }
            .offset(y: self.scrollOffset)
        }
        //.content.offset(y: self.scrollOffset)
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause: ()  // TODO: if a letter, tag the caption
            case .edit: self.insertCharacter(notification.object as! String)
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
            case .pause, .edit: self.incrementSelectionIndex()
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.state.mode {
            case .play: self.state.transition(to: .pause)
            case .pause, .edit: self.decrementSelectionIndex()
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
            case .pause: self._deleteCaption()
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
                    DispatchQueue.main.async {
                        self.state.selectedIndex = self.findIndexFromTimestamp()
                    }
                }
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
