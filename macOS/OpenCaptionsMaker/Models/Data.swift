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
    var id: Int //UUID  // Random unique identifier of the caption
    var startTime: Float  // In seconds
    var endTime: Float  // In seconds
    var duration: Float  // In seconds
    var text: String  // Caption text
    var speaker: Int  // Used to differentiate between speakers in the background (for better transcribing)
    var style: Style
    
    init(id: Int = 0, startTime: Float = 0.0, endTime: Float = 0.0, text: String = "", style: Style = defaultStyle) {
        self.id = id //UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime - startTime
        self.text = text
        self.speaker = 0
        self.style = style
    }
}

struct JSONResult: Codable {
    var transcriptions: [Caption] = []
}

// Set the initial captions list
let initialCaptionsList: [Caption] = [Caption()]

class Style: Hashable, Identifiable, Codable, Equatable {
    let id: Int //UUID  // Random unique identifier of the style
    //var captionRef: UUID?  // If relevant to a single caption, captionRef will contain the id of the caption
    var symbol: String?  // The symbol (alphabetical) associated with this style
    var font: String // Includes bold, italic, underline, font, size, color
    //var size: Int
    //var fontFace:
    //var color: Color
    var xPos: Float  // horizontal position of the caption
    var yPos: Float  // vertical position of the caption
    var alignment: String  // Alignment of the text
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    init(symbol: String?, font: String, xPos: Float, yPos: Float, alignment: String) {
        self.id = 0 //UUID()
        self.symbol = symbol
        self.font = font
        self.xPos = xPos
        self.yPos = yPos
        self.alignment = alignment
    }
}
// Need the following func to make Style conform to Equatable
func == (lhs: Style, rhs: Style) -> Bool {
    return lhs.symbol == rhs.symbol
}

let defaultStyle = Style(symbol: nil, font: "Arial", xPos: 0.0, yPos: 200.0, alignment: "Center")

// Sample data for testing purposes
var sampleCaptionData: [Caption] = load("styledCaptions")
