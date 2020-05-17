//
//  Utilities.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import AppKit

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
