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
    static let returnKey = Notification.Name("returnKey")
    static let spacebar = Notification.Name("spacebar")
    static let backspace = Notification.Name("backspace")
    static let escape = Notification.Name("escape")
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
            NotificationCenter.default.post(name: .returnKey, object: nil)
        }
        else if event.keyCode == 49 {  // spacebar
            NotificationCenter.default.post(name: .spacebar, object: nil)
        }
        else if event.keyCode == 51 {  // delete
            NotificationCenter.default.post(name: .backspace, object: nil)
        }
        else if event.keyCode == 53 {  // escape
            NotificationCenter.default.post(name: .escape, object: nil)
        }
        else {
            guard let characters = event.characters else { return }
            NotificationCenter.default.post(name: .enterCharacter, object: characters)
        }
    }
    
}
