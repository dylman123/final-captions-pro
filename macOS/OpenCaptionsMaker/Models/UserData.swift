//
//  UserData.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 18/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import Foundation
import Combine

class UserData: ObservableObject {
    
    // The global array which is to be generated via transcription API and edited by the user
    @Published var captions: [Caption] = sampleCaptionData
    
    // A store of the imported video's URL
    var videoURL: URL = URL(fileURLWithPath: "")
    
}

var sampleCaptionData: [Caption] = load("captionDataLong")
