//
//  GenerateCaptions.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//
import AVFoundation

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
    
    var assetWriter: AVAssetWriter?
    var assetReader: AVAssetReader?
    let asset = AVAsset(url: URL(fileURLWithPath: videoPath))
    
    //  Create asset reader
    do {
        assetReader = try AVAssetReader(asset: asset)
    } catch {
        assetReader = nil
    }
    guard let reader = assetReader else {
        fatalError("Could not initialize assetReader.")
    }
    
    //  Create audio track
    let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
    
    //  Define settings for the audio output reader
    let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
    if reader.canAdd(assetReaderAudioOutput) {
        reader.add(assetReaderAudioOutput)
    } else {
        fatalError("Couldn't add audio output reader.")
    }
    
    //  Create the AVAssetWriterInput & dispatch queue
    let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
    let audioInputQueue = DispatchQueue(label: "audioQueue")
    
    //  Write to the new asset
    let audioPath: String = "./temp/audiofile.wav"
    do {
        assetWriter = try AVAssetWriter(outputURL: URL(fileURLWithPath: audioPath), fileType: AVFileType.wav)
    } catch {
        assetWriter = nil
    }
    guard let writer = assetWriter else {
        fatalError("Could not initialize assetWriter.")
    }
    writer.shouldOptimizeForNetworkUse = true
    writer.add(audioInput)
    writer.startWriting()
    reader.startReading()
    writer.startSession(atSourceTime: kCMTimeEpochKey)
    
    
    
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
