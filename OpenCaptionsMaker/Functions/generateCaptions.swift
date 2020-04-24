//
//  GenerateCaptions.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

//  Top level function which is called upon video file import
func generateCaptions(forFile videoPath: String) {
    
    //  Extract audio from video file
    var audioPath: String = ""
    audioPath = extractAudio(fromVideoFile: videoPath)
    
    //  Transcribe audio using Google Cloud Speech to Text API
    var transcriptionData: [String:String] = ["":""]
    transcriptionData = transcribeAudio(ofAudioFile: audioPath)
    
    //  Form captions from the transcribed data
    var captionData: [String:String] = ["":""]
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

func formCaptions(fromData transcriptionData: [String:String]) -> [String:String] {
    
}
