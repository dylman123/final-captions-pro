//
//  Utilities.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

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
