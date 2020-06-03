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
    var id: Int = 0
    var startTime: Float = 0.0
    var endTime: Float = 0.0
    var duration: Float = 0.0
    var text: String = ""
    var speaker: Int = 0
    var tag: String = ""
}

struct JSONResult: Codable {
    var captions: [Caption] = []
}

// Set the initial captions list
let initialCaptionsList: [Caption] = [Caption()]

struct Style: Identifiable {
    var id: Int
    var symbol: String
    var font: CGFont
    //var size: Int
    //var fontFace:
    //var color: Color
    var position: CGPoint
    var alignment: TextAlignment
}
