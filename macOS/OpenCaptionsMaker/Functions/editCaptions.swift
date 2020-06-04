//
//  editCaptions.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 25/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

// Adds a blank caption into the row above the selected cell.
// The new caption's end time will match the caller caption's start time.
func addCaption(toArray arrayIn: [Caption], beforeIndex insertedIndex: Int, atTime end: Float) -> [Caption] {
    var captions = arrayIn
    
    // Increment all subsequent captions' ids
    for idx in 0..<captions.count {
        if captions[idx].index >= insertedIndex {
            captions[idx].index += 1
        }
    }
     
    // Compute timing values
    var prev_end: Float? {
        if insertedIndex != 0 { return captions[insertedIndex-1].endTime }
        else { return nil }
    }
    let buffer: Float = 1.0 // seconds before previous caption's start
    var start: Float {
        if prev_end == nil {  // if previous caption is at position 0
            return 0.0
        }
        else if end - prev_end! < buffer {  // if gap is smaller than buffer
            return prev_end!
        }
        else { return end - buffer }  // if gap is larger than buffer
    }
    let duration: Float = end - start
     
    let newCaption = Caption(
        index: insertedIndex,
        startTime: start,
        endTime: end,
        duration: duration,
        text: "",
        speaker: 0,
        tag: "")
     
    // Insert new Caption object
    captions.insert(newCaption, at: insertedIndex)
    
    return captions
}
 
// Deletes the selected cell
func deleteCaption(fromArray arrayIn: [Caption], atIndex deletedIndex: Int) -> [Caption] {
    var captions = arrayIn
    
    // Remove current Caption object from captions list
    captions.remove(at: deletedIndex)
     
    // Decrement all subsequent captions' ids
    for idx in 0..<captions.count {
        if captions[idx].index >= deletedIndex {
            captions[idx].index -= 1
        }
    }
    
    return captions
}
