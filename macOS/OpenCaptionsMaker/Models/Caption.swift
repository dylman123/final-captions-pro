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
    var id: Int
    var startTime: Float
    var endTime: Float
    var duration: Float
    var text: String
    var speaker: Int
}

struct JSONResult: Codable {
    var captions: [Caption] = []
}

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

// Set the initial captions list
let blankCaption: Caption = Caption (
    id: 0,
    startTime: 0.0,
    endTime: 0.0,
    duration: 0.0,
    text: "",
    speaker: 0)
let initialCaptionsList: [Caption] = [blankCaption]
