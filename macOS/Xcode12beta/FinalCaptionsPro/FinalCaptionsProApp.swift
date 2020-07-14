//
//  FinalCaptionsProApp.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 27/6/20.
//

import SwiftUI
import Firebase

// Boolean to quickly test edit UX
var isTestingEditUX: Bool = true

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        FirebaseApp.configure()
    }
}

@main
struct FinalCaptionsProApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let keyInputSubject = KeyInputSubjectWrapper()
    // Send keyboard shortcuts as notifications
    func postKeyPress(_ key: KeyEquivalent, object: Any?) {
        if key.character.isLetter {
            NotificationCenter.default.post(name: .character, object: String(key.character))
        }
        else {
            let notification = Notification.Name(String(describing: key))
            NotificationCenter.default.post(name: notification, object: object)
        }
    }
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .frame(minWidth: 1250, maxWidth: .infinity, minHeight: 700, maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: false)
                .onReceive(keyInputSubject) {
                    postKeyPress($0, object: nil)
                }
                .environmentObject(AppState())
        }
        .commands {
            CommandMenu("Navigate") {
                keyInput(.downArrow)
                keyInput(.upArrow)
                keyInput(.leftArrow)
                keyInput(.rightArrow)
                keyInput(.space)
                keyInput(.home)
                keyInput(.end)
            }
            CommandGroup(before: .textEditing) {
                keyInput(.return)
                keyInput(.tab, modifiers: .control)
                keyInput(.delete)
                keyInput(.deleteForward)
                keyInput(.escape, modifiers: .control)
                keyInput("+")
                keyInput("-")
            }
            CommandMenu("Tag") {
                Group{
                    keyInput("a")
                    keyInput("b")
                    keyInput("c")
                    keyInput("d")
                    keyInput("e")
                    keyInput("f")
                    keyInput("g")
                    keyInput("h")
                    keyInput("i")
                    keyInput("j")
                }
                Group {
                    keyInput("k")
                    keyInput("l")
                    keyInput("m")
                    keyInput("n")
                    keyInput("o")
                    keyInput("p")
                    keyInput("q")
                    keyInput("r")
                    keyInput("s")
                    keyInput("t")
                }
                Group {
                    keyInput("u")
                    keyInput("v")
                    keyInput("w")
                    keyInput("x")
                    keyInput("y")
                    keyInput("z")
                }
            }
        }
    }
}

// Used for integrated MacOS keyboard shortcuts
private extension FinalCaptionsProApp {
    func keyInput(_ key: KeyEquivalent, modifiers: EventModifiers = .none) -> some View {
        keyboardShortcut(key, sender: keyInputSubject, modifiers: modifiers)
    }
}
