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
    var speakerTag: Int
    var speakerName: String
    
}
