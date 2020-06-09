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
    let id: Int //UUID  // Random unique identifier of the style
    //var captionRef: UUID?  // If relevant to a single caption, captionRef will contain the id of the caption
    @Published var symbol: String?  // The symbol (alphabetical) associated with this style
    @Published var font: String
    @Published var size: CGFloat
    //var fontFace:
    @Published var color: Color
    @Published var position: CGSize
    @Published var alignment: TextAlignment  // Alignment of the text
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    init(symbol: String?, font: String, size: CGFloat, color: Color, position: CGSize, alignment: TextAlignment) {
        self.id = 0 //UUID()
        self.symbol = symbol
        self.font = font
        self.size = size
        self.color = color
        self.position = position
        self.alignment = alignment
    }
}
// Need the following func to make Style conform to Equatable
func == (lhs: Style, rhs: Style) -> Bool {
    return lhs.symbol == rhs.symbol
}

func defaultStyle() -> Style {
    // Set default style params
    let symbolD: String? = nil
    let fontD: String = "Georgia"
    let sizeD: CGFloat = 60.0
    let colorD: Color = .orange
    let positionD: CGSize = CGSize(width: 0.0, height: 200)
    let alignmentD: TextAlignment = .leading

    return Style (
        symbol: symbolD,
        font: fontD,
        size: sizeD,
        color: colorD,
        position: positionD,
        alignment: alignmentD
    )
}

// Sample data for testing purposes
var sampleCaptionData: [Caption] = load("captionDataLong")
