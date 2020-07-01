//
//  Caption.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import SwiftUI

struct Caption: Hashable, Identifiable, Codable {
    var id: Int  // Random unique identifier of the caption
    var start: Float  // In seconds
    var end: Float  // In seconds
    var duration: Float  // In seconds
    var text: String  // Caption text
    var speaker: Int  // Used to differentiate between speakers in the background (for better transcribing)
    var style: Style = defaultStyle()
    
    private enum CodingKeys: String, CodingKey {
        case id, start, end, duration, text, speaker
    }
    
    init(id: Int = 0, start: Float = 0.0, end: Float = 0.0, text: String = "", style: Style = defaultStyle()) {
        self.id = id //UUID()
        self.start = start
        self.end = end
        self.duration = end - start
        self.text = text
        self.speaker = 0
        self.style = style
    }
}

struct JSONResult: Codable {
    var captions: [Caption] = []
}

// Set the initial captions list
let initialCaptionsList: [Caption] = [Caption()]

// Sample data for testing purposes
var sampleCaptionData: [Caption] = load("captionDataLong")
