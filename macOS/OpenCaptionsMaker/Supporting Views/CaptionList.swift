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
    func setState(to newState: Mode) -> Void {
        state.mode = newState
        let notification = NSNotification.Name(String(describing: newState))
        NotificationCenter.default.post(name: notification, object: nil)
    }
    
    // Scroll logic
    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollBinding: Binding<CGPoint> = .constant(.zero)
    let scrollAmount: CGFloat = 45.0
    let scrollTrigger: Int = 11
    
    private var isAtPageEnd: Bool {
        let index = state.selectionIndex
        guard index > 0 else { return false }
        if index % scrollTrigger == 0 { return true }
        else { return false }
    }

    func animateOnCondition(_ condition: Bool, indexOperation: () -> (), scrollOperation: () -> ()) {
        if condition { withAnimation { indexOperation(); scrollOperation() } }
        else { indexOperation() }
    }
    
    func modifyStartTime(byStepSize delta: Float) -> Void {
        self.state.captions[self.state.selectionIndex].startTime += delta
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        self.state.captions[self.state.selectionIndex].endTime += delta
    }
    
    func _addCaption() -> Void {
        state.captions = addCaption(toArray: state.captions, beforeIndex: state.selectionIndex, atTime: state.captions[state.selectionIndex].startTime)
    }
    
    func _deleteCaption() -> Void {
        state.captions = deleteCaption(fromArray: state.captions, atIndex: state.selectionIndex)
        // If the last row is deleted, decrement selection
        if state.selectionIndex-1 == state.captions.count-1 {
            NotificationCenter.default.post(name: .upArrow, object: nil)
        }
    }
    
    func insertCharacter(_ char: String) -> Void {
        state.captions[state.selectionIndex].text += char
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
            case .play: self.setState(to: .pause)
            case .pause: ()  // TODO: if a letter, tag the caption
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.state.captions[self.state.selectionIndex].startTime)
                //strVal += String(describing: notification.object!)
                //self.state.captions[self.state.selectionIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.state.captions[self.state.selectionIndex].endTime)
                //strVal += String(describing: notification.object!)
                //self.state.captions[self.state.selectionIndex].endTime = (strVal as NSString).floatValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.state.mode {
            case .editStartTime: self.modifyStartTime(byStepSize: 0.1)
            case .editEndTime: self.modifyEndTime(byStepSize: 0.1)
            default: ()
            }
            
            guard self.state.selectionIndex < self.state.captions.count - 1 else { return } // Guard against when last caption is selected
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause, .edit:
                self.animateOnCondition(self.isAtPageEnd,
                indexOperation: { self.state.selectionIndex += 1 },
                scrollOperation: { self.scrollOffset -= self.scrollAmount * CGFloat(self.scrollTrigger) })
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.state.mode {
            case .editStartTime: self.modifyStartTime(byStepSize: -0.1)
            case .editEndTime: self.modifyEndTime(byStepSize: -0.1)
            default: ()
            }
            
            guard self.state.selectionIndex > 0 else { return } // Guard against when first caption is selected
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause, .edit:
                self.animateOnCondition(self.isAtPageEnd,
                indexOperation: { self.state.selectionIndex -= 1 },
                scrollOperation: { self.scrollOffset += self.scrollAmount * CGFloat(self.scrollTrigger) })
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: self._addCaption()
            case .edit: self.insertCharacter("+")
            case .editStartTime: self.modifyStartTime(byStepSize: 0.1)
            case .editEndTime: self.modifyEndTime(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            guard self.state.captions.count > 1 else { return }
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: self.insertCharacter("-")
            case .editStartTime: self.modifyStartTime(byStepSize: -0.1)
            case .editEndTime: self.modifyEndTime(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: self.setState(to: .edit)
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            case .editStartTime: self.setState(to: .edit)
            case .editEndTime: self.setState(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: ()
            case .edit: self.setState(to: .editStartTime)
            case .editStartTime: self.setState(to: .editEndTime)
            case .editEndTime: self.setState(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: _ = self.state.captions[self.state.selectionIndex].text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: self.setState(to: .play)
            case .edit: self.insertCharacter(" ")
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.state.mode {
            case .play: self.setState(to: .pause)
            case .pause: ()
            case .edit: self.setState(to: .pause)
            case .editStartTime: self.setState(to: .edit)
            case .editEndTime: self.setState(to: .edit)
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
