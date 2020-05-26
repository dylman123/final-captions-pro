//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // To refresh the UI when state changes
    @EnvironmentObject var stateEnvObj: AppState
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(stateEnvObj.captions) { caption in
                    CaptionRow(caption: caption)
                        .tag(caption)
                        .padding(.vertical, 10)
                        .offset(y: -50 * CGFloat(self.stateEnvObj.selectionIndex)) //FIXME: Corect the scrolling logic
                }
            }
        }
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: ()  // TODO: if a letter, tag the caption
            case .edit: state.captions[state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime:
                var strVal = String(state.captions[state.selectionIndex].startTime)
                strVal += String(describing: notification.object!)
                state.captions[state.selectionIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime:
                var strVal = String(state.captions[state.selectionIndex].endTime)
                strVal += String(describing: notification.object!)
                state.captions[state.selectionIndex].endTime = (strVal as NSString).floatValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch state.mode {
            case .editStartTime: state.captions[state.selectionIndex].startTime += 0.1
            case .editEndTime: state.captions[state.selectionIndex].endTime += 0.1
            default: ()
            }
            
            guard state.selectionIndex < state.captions.count-1 else { return } // Guard against when last caption is selected
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: state.selectionIndex += 1
            case .edit: state.selectionIndex += 1
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch state.mode {
            case .editStartTime: state.captions[state.selectionIndex].startTime -= 0.1
            case .editEndTime: state.captions[state.selectionIndex].endTime -= 0.1
            default: ()
            }
            
            guard state.selectionIndex > 0 else { return } // Guard against when first caption is selected
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: state.selectionIndex -= 1
            case .edit: state.selectionIndex -= 1
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: addCaption(beforeIndex: state.selectionIndex, atTime: state.captions[state.selectionIndex].startTime)
            case .edit: state.captions[state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime: state.captions[state.selectionIndex].startTime += 0.1
            case .editEndTime: state.captions[state.selectionIndex].endTime += 0.1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            guard state.captions.count > 1 else { return }
            switch state.mode {
            case .play: state.mode = .pause
            case .pause:
                deleteCaption(atIndex: state.selectionIndex)
                // If the last row is deleted, decrement selection
                if state.selectionIndex-1 == state.captions.count-1 {
                    NotificationCenter.default.post(name: .upArrow, object: nil)
                }
            case .edit: state.captions[state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime: state.captions[state.selectionIndex].startTime -= 0.1
            case .editEndTime: state.captions[state.selectionIndex].endTime -= 0.1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: state.mode = .edit
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            case .editStartTime: state.mode = .edit
            case .editEndTime: state.mode = .edit
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: ()
            case .edit: state.mode = .editStartTime
            case .editStartTime: state.mode = .editEndTime
            case .editEndTime: state.mode = .edit
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: ()
            case .edit: _ = state.captions[state.selectionIndex].text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: state.mode = .play
            case .edit: state.captions[state.selectionIndex].text += " "
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch state.mode {
            case .play: state.mode = .pause
            case .pause: ()
            case .edit: state.mode = .pause
            case .editStartTime: state.mode = .edit
            case .editEndTime: state.mode = .edit
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
