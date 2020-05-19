//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

enum Mode {
    case playback, select, edit
}

class CaptionListState: ObservableObject {
    @Published var mode = Mode.select
    @Published var selectionIndex = 0
}

struct CaptionList: View {
    
    // To refresh the UI when userData changes
    @EnvironmentObject var userDataEnvObj: UserData
    
    // Track the state of the CaptionList view
    @State var state = CaptionListState()
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(userDataEnvObj.captions) { caption in
                    CaptionRow(caption: caption)
                        .environmentObject(self.state)
                        .tag(caption)
                        .padding(.vertical, 10)
                }
            }
        }
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            switch self.state.mode {
            case .playback: self.state.mode = .select
            case .select: ()  // TODO: if a letter, the caption
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            guard self.state.selectionIndex < userData.captions.count-1 else { return }
            switch self.state.mode {
            case .playback: self.state.mode = .select
            case .select: self.state.selectionIndex += 1
            case .edit: self.state.selectionIndex += 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            guard self.state.selectionIndex > 0 else { return }
            switch self.state.mode {
            case .playback: self.state.mode = .select
            case .select: self.state.selectionIndex -= 1
            case .edit: self.state.selectionIndex -= 1
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.state.mode {
            case .playback: ()
            case .select: addCaption(beforeIndex: self.state.selectionIndex, atTime: userData.captions[self.state.selectionIndex].start)
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            guard userData.captions.count > 1 else { return }
            switch self.state.mode {
            case .playback: ()
            case .select:
                deleteCaption(atIndex: self.state.selectionIndex)
                // If the last row is deleted, decrement selection
                if self.state.selectionIndex-1 == userData.captions.count-1 {
                    NotificationCenter.default.post(name: .upArrow, object: nil)
                }
            case .edit: userData.captions[self.state.selectionIndex].text += String(describing:  notification.object!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.state.mode {
            case .playback: ()
            case .select: self.state.mode = .edit
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.state.mode {
            case .playback: ()
            case .select: ()
            case .edit: _ = userData.captions[self.state.selectionIndex].text.popLast()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.state.mode {
            case .playback: self.state.mode = .select
            case .select: self.state.mode = .playback
            case .edit: userData.captions[self.state.selectionIndex].text += " "
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.state.mode {
            case .playback: ()
            case .select: ()
            case .edit: self.state.mode = .select
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
