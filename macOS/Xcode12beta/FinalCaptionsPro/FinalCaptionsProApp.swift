//
//  FinalCaptionsProApp.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 27/6/20.
//

import SwiftUI
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let downArrow = HotKey(key: .downArrow, modifiers: [])
    let upArrow = HotKey(key: .upArrow, modifiers: [])
    let rightArrow = HotKey(key: .rightArrow, modifiers: [])  // Must make available for TextField
    let leftArrow = HotKey(key: .leftArrow, modifiers: [])  // Must make available for TextField
    let plus = HotKey(key: .equal, modifiers: [.shift])  // Must make available for TextField
    let minus = HotKey(key: .minus, modifiers: [])  // Must make available for TextField
    let returnKey = HotKey(key: .return, modifiers: [])
    let tab = HotKey(key: .tab, modifiers: [])
    let spacebar = HotKey(key: .space, modifiers: [])  // Must make available for TextField
    let delete = HotKey(key: .delete, modifiers: [])  // Must make available for TextField
    let forwardDelete = HotKey(key: .forwardDelete, modifiers: [])  // Must make available for TextField
    let escape = HotKey(key: .escape, modifiers: [])
    let undo = HotKey(key: .z, modifiers: [.command])  // Must make available for TextField
    let copy = HotKey(key: .c, modifiers: [.command])  // Must make available for TextField
    let paste = HotKey(key: .v, modifiers: [.command])  // Must make available for TextField

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        downArrow.keyDownHandler = { print("DOWN") }
        copy.keyDownHandler = { print("COPY") }
        paste.keyDownHandler = { print("PASTE") }
        delete.keyDownHandler = { print("DEL") }
        forwardDelete.keyDownHandler = { print("FWD DEL") }
        plus.keyDownHandler = { print("PLUS") }
        minus.keyDownHandler = { print("MINUS") }
    }
}

@main
struct FinalCaptionsProApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AppState())
        }
    }
}
