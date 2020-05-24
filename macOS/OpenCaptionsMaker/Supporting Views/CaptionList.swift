//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

enum Mode {
    case play, pause, edit, editStartTime, editEndTime
}

class CaptionListState: ObservableObject {
    @Published var mode = Mode.pause
    @Published var selectionIndex = 0
}

struct CaptionList: View {
    
    // To refresh the UI when userData changes
    @EnvironmentObject var userDataEnvObj: UserData
    
    // Track the state of the CaptionList view
    @State var state = CaptionListState()
    
    //init() {
    //    _ = state.objectWillChange.sink { [unowned state] in
    //        state.objectWillChange.send()
    //    }
    //}
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(userDataEnvObj.captions) { caption in
                    CaptionRow(caption: caption)
                        .environmentObject(self.state)
                        .tag(caption)
                        .padding(.vertical, 10)
                        .offset(y: -50 * CGFloat(self.state.selectionIndex))  // FIXME: Why doesn't this refresh the UI in realtime?
                }
            }
        }
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: ()  // TODO: if a letter, tag the caption
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime:
                var strVal = String(userData.captions[self.state.selectionIndex].startTime)
                strVal += String(describing: notification.object!)
                userData.captions[self.state.selectionIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime:
                var strVal = String(userData.captions[self.state.selectionIndex].endTime)
                strVal += String(describing: notification.object!)
                userData.captions[self.state.selectionIndex].endTime = (strVal as NSString).floatValue
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.state.mode {
            case .editStartTime: userData.captions[self.state.selectionIndex].startTime += 0.1
            case .editEndTime: userData.captions[self.state.selectionIndex].endTime += 0.1
            default: ()
            }
            
            guard self.state.selectionIndex < userData.captions.count-1 else { return } // Guard against when last caption is selected
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: self.state.selectionIndex += 1
            case .edit: self.state.selectionIndex += 1
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.state.mode {
            case .editStartTime: userData.captions[self.state.selectionIndex].startTime -= 0.1
            case .editEndTime: userData.captions[self.state.selectionIndex].endTime -= 0.1
            default: ()
            }
            
            guard self.state.selectionIndex > 0 else { return } // Guard against when first caption is selected
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: self.state.selectionIndex -= 1
            case .edit: self.state.selectionIndex -= 1
            default: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: addCaption(beforeIndex: self.state.selectionIndex, atTime: userData.captions[self.state.selectionIndex].startTime)
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime: userData.captions[self.state.selectionIndex].startTime += 0.1
            case .editEndTime: userData.captions[self.state.selectionIndex].endTime += 0.1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            guard userData.captions.count > 1 else { return }
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause:
                deleteCaption(atIndex: self.state.selectionIndex)
                // If the last row is deleted, decrement selection
                if self.state.selectionIndex-1 == userData.captions.count-1 {
                    NotificationCenter.default.post(name: .upArrow, object: nil)
                }
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            case .editStartTime: userData.captions[self.state.selectionIndex].startTime -= 0.1
            case .editEndTime: userData.captions[self.state.selectionIndex].endTime -= 0.1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: self.state.mode = .edit
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            case .editStartTime: self.state.mode = .edit
            case .editEndTime: self.state.mode = .edit
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: ()
            case .edit: self.state.mode = .editStartTime
            case .editStartTime: self.state.mode = .editEndTime
            case .editEndTime: self.state.mode = .edit
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: ()
            case .edit: _ = userData.captions[self.state.selectionIndex].text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: self.state.mode = .play
            case .edit: userData.captions[self.state.selectionIndex].text += " "
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.state.mode {
            case .play: self.state.mode = .pause
            case .pause: ()
            case .edit: self.state.mode = .pause
            case .editStartTime: self.state.mode = .edit
            case .editEndTime: self.state.mode = .edit
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
