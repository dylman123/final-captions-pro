//
//  TypingWindow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let addCaption = Notification.Name("addCaption")
    static let deleteCaption = Notification.Name("deleteCaption")
    static let moveDown = Notification.Name("moveDown")
    static let moveUp = Notification.Name("moveUp")
    static let toggleEdit = Notification.Name("toggleEdit")
    static let enterCharacter = Notification.Name("enterCharacter")
}

class TypingWindow: NSWindow {

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 24 {  // plus
            NotificationCenter.default.post(name: .addCaption, object: nil)
        }
        else if event.keyCode == 27 {  // minus
            NotificationCenter.default.post(name: .deleteCaption, object: nil)
        }
        else if event.keyCode == 125 {  // down arrow
            NotificationCenter.default.post(name: .moveDown, object: nil)
        }
        else if event.keyCode == 126 {  // up arrow
            NotificationCenter.default.post(name: .moveUp, object: nil)
        }
        else if event.keyCode == 36 {  // return
            NotificationCenter.default.post(name: .toggleEdit, object: nil)
        }
        else {
            guard let characters = event.characters else { return }
            NotificationCenter.default.post(name: .enterCharacter, object: characters)
        }
    }
    
}
