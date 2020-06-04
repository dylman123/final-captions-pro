//
//  Caption.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation
import SwiftUI

struct Caption: Hashable, Codable, Identifiable {
    let id = UUID()  // Random unique identifier of the caption
    var startTime: Float = 0.0  // In seconds
    var endTime: Float = 0.0  // In seconds
    var duration: Float = 0.0  // In seconds
    var text: String = ""  // Caption text
    var speaker: Int = 0  // Used to differentiate between speakers in the background (for better transcribing)
}

struct EditableCaption {
    let caption: Caption  // Stores caption data
    var index: Int = 0  // Current List index
    var style: Style  // Associated with the style object's symbol property
}

struct JSONResult: Codable {
    var captions: [Caption] = []
}

// Set the initial captions list
let initialCaptionsList: [Caption] = [Caption()]

struct Style: Identifiable {
    let id = UUID()  // Random unique identifier of the style
    var captionRef: UUID?  // If relevant to a single caption, captionRef will contain the id of the caption
    var symbol: Character  // The symbol (alphabetical) associated with this style
    var font = ""  // Includes bold, italic, underline, font, size, color
    //var size: Int
    //var fontFace:
    //var color: Color
    var position: CGPoint  // x,y coords of the caption
    var alignment = ""  // Alignment of the text
}
