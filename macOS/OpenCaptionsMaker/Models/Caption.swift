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
    var start: Float
    var end: Float
    var duration: Float
    var text: String
    var speaker: Int
}

struct JSONResult: Codable {
    
    var captions: [Caption] = []
}

// Set the initial captions list
let blankCaption: Caption = Caption (
    id: 0,
    start: 0.0,
    end: 0.0,
    duration: 0.0,
    text: "",
    speaker: 0)
let initialCaptionsList: [Caption] = [blankCaption]
