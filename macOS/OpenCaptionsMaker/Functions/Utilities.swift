//
//  Utilities.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import AppKit

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
}

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

// Loads a JSON structure from file
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: "json")
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
