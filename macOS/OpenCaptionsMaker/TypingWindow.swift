//
//  TypingWindow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let plus = Notification.Name("plus")
    static let minus = Notification.Name("minus")
    static let downArrow = Notification.Name("downArrow")
    static let upArrow = Notification.Name("upArrow")
    static let leftArrow = Notification.Name("leftArrow")
    static let rightArrow = Notification.Name("rightArrow")
    static let returnKey = Notification.Name("returnKey")
    static let tab = Notification.Name("tab")
    static let spacebar = Notification.Name("spacebar")
    static let delete = Notification.Name("delete")
    static let escape = Notification.Name("escape")
    static let character = Notification.Name("character")
    static let play = Notification.Name("play")
    static let pause = Notification.Name("pause")
    static let edit = Notification.Name("edit")
}

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
