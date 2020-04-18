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
    
    // Adds a blank caption into the row above the selected cell
    func addCaption(beforeIndex id: Int, atTime end: Float) {
        
        #if DEBUG
        print("Before adding: \n")
        for caption in captions {
            print(caption.id)
        }
        #endif
        
        // Increment all subsequent captions' ids
         for var caption in captions {
             if caption.id >= id {
                 caption.id += 1
             }
         }
        
        let buffer: Float = 1.0 // seconds before previous caption's start
        let start: Float = end - buffer
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
        print("After adding: \n")
        for caption in captions {
            print(caption.id)
        }
        #endif
    }
    
    // Deletes the selected cell
    func deleteCaption(atIndex id: Int) {
        
        #if DEBUG
        print("Before deleting: \n")
        for caption in captions {
            print(caption.id)
        }
        #endif
        
        // Remove current Caption object from captions list
        self.captions.remove(at: id)
        
        // Decrement all subsequent captions' ids
        for var caption in captions {
            if caption.id >= id {
                caption.id -= 1
            }
        }
        
        #if DEBUG
        print("After deleting: \n")
        for caption in captions {
            print(caption.id)
        }
        #endif
    }
    
}
