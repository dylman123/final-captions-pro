//
//  Caption.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation
import SwiftUI

struct Caption: Hashable, Identifiable, Codable {
    var id: Int //UUID  // Random unique identifier of the caption
    var startTime: Float  // In seconds
    var endTime: Float  // In seconds
    var duration: Float  // In seconds
    var text: String  // Caption text
    var speaker: Int  // Used to differentiate between speakers in the background (for better transcribing)
    var style: Style = defaultStyle()
    
    private enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, duration, text, speaker
    }
    
    init(id: Int = 0, startTime: Float = 0.0, endTime: Float = 0.0, text: String = "", style: Style = defaultStyle()) {
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

class Style: Hashable, Identifiable, Equatable, ObservableObject {
    let id: Int  // Random unique identifier of the style
    @Published var symbol: String?  // The symbol (alphabetical) associated with this style
    @Published var font: String
    @Published var size: CGFloat
    @Published var color: NSColor
    @Published var position: CGSize
    @Published var alignment: TextAlignment  // Alignment of the text
    @Published var bold: Bool
    @Published var italic: Bool
    @Published var underline: Bool
    @Published var strikethrough: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    init(symbol: String?, font: String, size: CGFloat, color: NSColor, position: CGSize, alignment: TextAlignment, bold: Bool, italic: Bool, underline: Bool, strikethrough: Bool) {
        self.id = 0 //UUID()
        self.symbol = symbol
        self.font = font
        self.size = size
        self.color = color
        self.position = position
        self.alignment = alignment
        self.bold = bold
        self.italic = italic
        self.underline = underline
        self.strikethrough = strikethrough
    }
}
// Need the following func to make Style conform to Equatable
func == (lhs: Style, rhs: Style) -> Bool {
    return lhs.symbol == rhs.symbol
}

func defaultStyle() -> Style {
    // Set default style params
    let _symbol: String? = nil
    let _font: String = "Arial"
    let _size: CGFloat = 60.0
    let _color: NSColor = .white
    let _position: CGSize = CGSize(width: 0.0, height: 200)
    let _alignment: TextAlignment = .leading
    let _bold: Bool = false
    let _italic: Bool = false
    let _underline: Bool = false
    let _strikethrough: Bool = false
    
    let fontFamilyNames = NSFontManager.shared.availableFontFamilies
    print("avaialble fonts is \(fontFamilyNames)")
    
    return Style (
        symbol: _symbol,
        font: _font,
        size: _size,
        color: _color,
        position: _position,
        alignment: _alignment,
        bold: _bold,
        italic: _italic,
        underline: _underline,
        strikethrough: _strikethrough
    )
}

// Sample data for testing purposes
var sampleCaptionData: [Caption] = load("captionDataLong")
