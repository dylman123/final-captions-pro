//
//  TypingWindow.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import Cocoa
import HotKey

class TypingWindow: NSWindow {

    // The key presses defined here will NOT be the first responder
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
//        case 48: notification = .tab
        case 49: notification = .spacebar
        case 51: notification = .delete
//        case 53: notification = .escape
        default: notification = .character
        }
        NotificationCenter.default.post(name: notification, object: character)
    }
}
