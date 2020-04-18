//
//  UserData.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UserData: ObservableObject {
    
    @Published var captions: [Caption] = captionData
    
    // Adds a blank caption into the row above the selected cell.
    // The new caption's end time will match the caller caption's start time.
    func addCaption(beforeIndex id: Int, atTime end: Float) {
        
        #if DEBUG
        print("Before adding caption \(id):")
        for caption in self.captions {
            print(caption.id)
        }
        #endif
        
        // Increment all subsequent captions' ids
        for caption in self.captions {
            if caption.id >= id {
                self.captions[id].id += 1
            }
         }
        
        // Compute timing values
        var prev_end: Float? {
            do { return try self.captions[id-1].end } catch { return nil }
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
            id: id,
            start: start,
            end: end,
            duration: duration,
            text: "",
            speakerTag: 0,
            speakerName: "")
        
        // Insert new Caption object
        self.captions.insert(newCaption, at: id)
        
        #if DEBUG
        print("After adding caption \(id):")
        for caption in self.captions {
            print(caption.id)
        }
        #endif
    }
    
    // Deletes the selected cell
    func deleteCaption(atIndex id: Int) {
        
        #if DEBUG
        print("Before deleting caption \(id):")
        for caption in self.captions {
            print(caption.id)
        }
        #endif
        
        // Remove current Caption object from captions list
        self.captions.remove(at: id)
        
        // Decrement all subsequent captions' ids
        for var caption in self.captions {
            if caption.id >= id {
                self.captions[id].id -= 1
            }
        }
        
        #if DEBUG
        print("After deleting caption \(id):")
        for caption in self.captions {
            print(caption.id)
        }
        #endif
    }
}
