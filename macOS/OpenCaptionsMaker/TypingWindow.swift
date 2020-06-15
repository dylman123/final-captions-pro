//
//  TypingWindow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Cocoa

class TypingWindow: NSWindow {

    override func keyDown(with event: NSEvent) {
        guard let character = event.characters else { return }
        var notification: Notification.Name
        switch event.keyCode {
        case 24: notification = .plus
        case 27: notification = .minus
        case 125: notification = .downArrow
        case 126: notification = .upArrow
        case 123: notification = .leftArrow
        case 124: notification = .rightArrow
        case 36: notification = .returnKey
        case 48: notification = .tab
        case 49: notification = .spacebar
        case 51: notification = .delete
        case 53: notification = .escape
        default: notification = .character
        }
        NotificationCenter.default.post(name: notification, object: character)
    }
}
