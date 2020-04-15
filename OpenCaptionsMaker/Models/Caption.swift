//
//  Caption.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation

struct Caption: Hashable, Codable {
    var id: Int
    var start: Float
    var end: Float
    var duration: Float
    var text: String
    var speakerTag: Int
    var speakerName: String
    
}
