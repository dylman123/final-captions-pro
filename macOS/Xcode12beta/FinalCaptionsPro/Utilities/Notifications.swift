//
//  Notifications.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation

// Custom notifications to send instructions between (and within) views
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
    static let fwdDelete = Notification.Name("fwdDelete")
    static let escape = Notification.Name("escape")
    static let character = Notification.Name("character")
    static let play = Notification.Name("play")
    static let pause = Notification.Name("pause")
    static let edit = Notification.Name("edit")
    static let seekVideo = Notification.Name("seekVideo")
    static let seekList = Notification.Name("seekList")
    static let nextPage = Notification.Name("nextPage")
    static let prevPage = Notification.Name("prevPage")
    static let updateStyle = Notification.Name("updateStyle")
    static let updateColor = Notification.Name("updateColor")
    static let scroll = Notification.Name("scroll")
    static let undo = Notification.Name("undo")
    static let copy = Notification.Name("copy")
    static let paste = Notification.Name("paste")
}
