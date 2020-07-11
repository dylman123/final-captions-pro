//
//  FinalCaptionsProApp.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 27/6/20.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }
}

@main
struct FinalCaptionsProApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
//    private let keyInputSubject = KeyInputSubjectWrapper()
//    func postKeyPress(_ key: KeyEquivalent, object: Any?) {
//        print(key)
//        let notification = Notification.Name(String(describing: key))
//        NotificationCenter.default.post(name: notification, object: object)
//    }
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: false)
//                .onReceive(keyInputSubject) {
//                    postKeyPress($0, object: nil)
//                }
                //.environmentObject(keyInputSubject)
                .background(KeyEventHandling())
                .environmentObject(AppState())
        }
//        .commands {
//            CommandMenu("Navigate") {
////                keyInput(.downArrow)
////                keyInput(.upArrow)
////                keyInput(.leftArrow)
////                keyInput(.rightArrow)
//                keyInput(.space)
//                keyInput(.home)
//                keyInput(.end)
//            }
//            CommandGroup(before: .help) {
//                keyInput(.return)
//                keyInput(.tab, modifiers: .control)
//                keyInput(.delete)
//                keyInput(.deleteForward)
//                //keyInput(.escape, modifiers: .control)
//            }
//        }
    }
}

// Used for integrated MacOS keyboard shortcuts
//private extension FinalCaptionsProApp {
//    func keyInput(_ key: KeyEquivalent, modifiers: EventModifiers = .none) -> some View {
//        keyboardShortcut(key, sender: keyInputSubject, modifiers: modifiers)
//    }
//}

// Used for alphanumeric keypresses
struct KeyEventHandling: NSViewRepresentable {
   
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            super.keyDown(with: event)
            //print(">> key \(event.charactersIgnoringModifiers ?? "")")
            print(">> key \(event.keyCode)")
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

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async { // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
    }
}

//func postKeyPress(with event: NSEvent) {
//    guard let character = event.characters else { return }
//    var notification: Notification.Name
//    switch event.keyCode {
//    case 24: notification = .plus
//    case 27: notification = .minus
//    case 125: notification = .downArrow
//    case 126: notification = .upArrow
//    case 123: notification = .leftArrow
//    case 124: notification = .rightArrow
//    case 36: notification = .returnKey
//    case 48: notification = .tab
//    case 49: notification = .spacebar
//    case 51: notification = .delete
//    case 53: notification = .escape
//    default: notification = .character
//    }
//    NotificationCenter.default.post(name: notification, object: character)
//}
