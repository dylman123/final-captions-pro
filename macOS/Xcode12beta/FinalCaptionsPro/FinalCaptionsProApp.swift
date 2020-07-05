//
//  FinalCaptionsProApp.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 27/6/20.
//

import SwiftUI
import HotKey
import Firebase

class AppDelegate: NSObject, NSApplicationDelegate {

    // These HotKeys will be the first responder
//    let downArrow = HotKey(key: .downArrow, modifiers: [])
//    let upArrow = HotKey(key: .upArrow, modifiers: [])
//    let returnKey = HotKey(key: .return, modifiers: [])
    let tab = HotKey(key: .tab, modifiers: [])
    let escape = HotKey(key: .escape, modifiers: [])
//    let undo = HotKey(key: .z, modifiers: [.command])
//    let copy = HotKey(key: .c, modifiers: [.command])
//    let paste = HotKey(key: .v, modifiers: [.command])

    var window: NSWindow!

    func post(_ notification: Notification.Name, object: Any?) {
        NotificationCenter.default.post(name: notification, object: object)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        downArrow.keyDownHandler = { self.post(.downArrow, object: nil) }
//        upArrow.keyDownHandler = { self.post(.upArrow, object: nil) }
//        returnKey.keyDownHandler = { self.post(.returnKey, object: nil) }
        tab.keyDownHandler = { self.post(.tab, object: nil) }
        escape.keyDownHandler = { self.post(.escape, object: nil) }
//        undo.keyDownHandler = { self.post(.undo, object: nil) }
//        copy.keyDownHandler = { self.post(.copy, object: nil) }
//        paste.keyDownHandler = { self.post(.delete, object: nil) }

        // Configure Firebase
        FirebaseApp.configure()
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(AppState())

        window = TypingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}

@main
struct FinalCaptionsProApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            //ContentView().environmentObject(AppState())
            Text("Welcome to Final Captions Pro.")
                .scaledToFill()
                .padding()
        }
    }
}
