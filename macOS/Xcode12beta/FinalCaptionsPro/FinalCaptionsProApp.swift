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

    func post(_ notification: Notification.Name, object: Any?) {
        NotificationCenter.default.post(name: notification, object: object)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        downArrow.keyDownHandler = { self.post(.downArrow, object: nil) }
        upArrow.keyDownHandler = { self.post(.upArrow, object: nil) }
        rightArrow.keyDownHandler = { self.post(.rightArrow, object: nil) }
        leftArrow.keyDownHandler = { self.post(.leftArrow, object: nil) }
        plus.keyDownHandler = { self.post(.plus, object: nil) }
        minus.keyDownHandler = { self.post(.minus, object: nil) }
        returnKey.keyDownHandler = { self.post(.returnKey, object: nil) }
        tab.keyDownHandler = { self.post(.tab, object: nil) }
        spacebar.keyDownHandler = { self.post(.spacebar, object: nil) }
        delete.keyDownHandler = { self.post(.delete, object: nil) }
        forwardDelete.keyDownHandler = { self.post(.fwdDelete, object: nil) }
        escape.keyDownHandler = { self.post(.escape, object: nil) }
        undo.keyDownHandler = { self.post(.undo, object: nil) }
        copy.keyDownHandler = { self.post(.copy, object: nil) }
        paste.keyDownHandler = { self.post(.delete, object: nil) }
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
