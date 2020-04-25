//
//  GenerateCaptions.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//
//  generateCaptions() is the top level function which is called upon video file import.
//    - Input: Video filepath
//    - Output: Array of Caption objects, returned as captionData

func generateCaptions(forFile videoPath: String) -> [Caption] {
    
    //  Extract audio from video file
    var audioPath: String = ""
    audioPath = extractAudio(fromVideoFile: videoPath)
    
    //  Transcribe audio using Google Cloud Speech to Text API
    var transcriptionData: [String:String] = ["":""]
    transcriptionData = transcribeAudio(ofAudioFile: audioPath)
    
    //  Form captions from the transcribed data
    var captionData: [Caption]
    captionData = formCaptions(fromData: transcriptionData)
    
    return captionData
}

func extractAudio(fromVideoFile videoPath: String) -> String {
    var audioPath: String = ""
    
    //  Insert code to convert video to single channel audio
    
    return audioPath
}

func transcribeAudio(ofAudioFile audioPath: String) -> [String:String] {
    var transcriptionData: [String:String] = ["":""]
    
    //  Insert code to transcribe audio
    
    return transcriptionData
}

func formCaptions(fromData transcriptionData: [String:String]) -> [Caption] {
    var captionData: [Caption] = []
    //  Insert code to form captions from a JSON structured API response
    
    return captionData
}
