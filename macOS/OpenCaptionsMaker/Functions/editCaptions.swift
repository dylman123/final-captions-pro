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
func addCaption(toArray arrayIn: [StyledCaption], beforeIndex insertedIndex: Int, atTime end: Float) -> [StyledCaption] {
    var userData = arrayIn
    
    // Increment all subsequent captions' ids
    for idx in 0..<userData.count {
        if userData[idx].id >= insertedIndex {
            userData[idx].id += 1
        }
    }
     
    // Compute timing values
    var prev_end: Float? {
        if insertedIndex != 0 { return userData[insertedIndex-1].caption.endTime }
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
     
    let newCaption = Caption(startTime: 0.0, endTime: 0.0, text: "")
    let styledCaption = StyledCaption(id: 0, caption: newCaption, style: defaultStyle)
    
    // Insert new Caption object
    userData.insert(styledCaption, at: insertedIndex)
    
    return userData
}
 
// Deletes the selected cell
func deleteCaption(fromArray arrayIn: [StyledCaption], atIndex deletedIndex: Int) -> [StyledCaption] {
    var userData = arrayIn
    
    // Remove current Caption object from captions list
    userData.remove(at: deletedIndex)
     
    // Decrement all subsequent captions' ids
    for idx in 0..<userData.count {
        if userData[idx].id >= deletedIndex {
            userData[idx].id -= 1
        }
    }
    
    return userData
}
