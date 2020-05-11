//
//  Utilities.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import AppKit
import SwiftUI

// Send commands to bash shell
func shell(_ command: String) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

    return output
}

// Get the local project's documents directory
// This is a directory where the project has permissions to save files
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

// Handle keyboard presses
struct KeyEventHandling: NSViewRepresentable {
    
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            super.keyDown(with: event)
            print(">> key \(event.charactersIgnoringModifiers ?? "")")
        }
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async {  // Wait until next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
    }
}
