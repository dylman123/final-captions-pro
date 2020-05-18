//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // To refresh the UI when userData changes
    @EnvironmentObject var userDataEnvObj: UserData
    
    // Track the the selected caption
    @State private var selectedCaption = 0
    
    // Track the mode (select or edit mode)
    @State private var isInEditMode = false
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(userDataEnvObj.captions) { caption in
                    CaptionRow(selectedCaption: self.selectedCaption, isEdited: self.isInEditMode, caption: caption)
                    .tag(caption)
                    .padding(.vertical, 10)
                }
            }
        }
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .moveDown)) { _ in
            guard self.selectedCaption < userData.captions.count-1 else { return }
            self.selectedCaption += 1
            }
        .onReceive(NotificationCenter.default.publisher(for: .moveUp)) { _ in
            guard self.selectedCaption > 0 else { return }
            self.selectedCaption -= 1
            }
        .onReceive(NotificationCenter.default.publisher(for: .addCaption)) { _ in
            if !self.isInEditMode {
                addCaption(beforeIndex: self.selectedCaption, atTime: userData.captions[self.selectedCaption].start)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteCaption)) { _ in
            guard userData.captions.count > 1 else { return }
            if !self.isInEditMode {
                deleteCaption(atIndex: self.selectedCaption)
            }
            // If the last row is deleted, decrement selection
            if self.selectedCaption-1 == userData.captions.count-1 {
                NotificationCenter.default.post(name: .moveUp, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            if self.isInEditMode {
                NotificationCenter.default.post(name: .moveDown, object: nil)
            } else {
                self.isInEditMode.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .enterCharacter)) { notification in
            guard notification.object != nil else { return }
            if self.isInEditMode {
                userData.captions[self.selectedCaption].text += String(describing:  notification.object!)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .backspace)) { _ in
            if self.isInEditMode {
                _ = userData.captions[self.selectedCaption].text.popLast()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            if self.isInEditMode {
                userData.captions[self.selectedCaption].text += " "
            } else {
                self.isInEditMode.toggle()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            if self.isInEditMode {
                self.isInEditMode.toggle()
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
