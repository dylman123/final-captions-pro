//
//  UserAPI.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 20/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import Firebase

enum TranscriptionState {
    case idle
    case videoSelected
    case extractedAudio(Result<URL, APIError>)
    case convertedAudio(Result<URL, APIError>)
    case uploadedAudio(Result<(StorageReference, String), APIError>)
    case downloadedJSON(Result<(StorageReference, [Caption]), APIError>)
    case deletedTemp(Result<String, APIError>)
}

//enum APIState<T> {
//    case dormant
//    case loading
//    case fetched(Result<T, APIError>)
//    case notauthorized
//    case notfound
//    case servererror
//}
//
enum APIError: Error {
    case error(String)

    var localizedDescription: String {
        switch self {
        case .error(let message):
            return message
        }
    }
}
//
//class UserAPI {
//
//    public static let shared = UserAPI()
//    private init() {}
//
//}

class CaptionMaker: ObservableObject {
    
    @Published var state: TranscriptionState = .idle

    // Top level function
    func generateCaptions() {
        self.state = .videoSelected
    }
        
    // Extract audio from video file and asynchronously return result in a closure
    func extractAudio(fromFile sourceURL: URL) {
        
        // Check format conversion compatibility (to m4a)
        let videoAsset = AVURLAsset(url: sourceURL)
        AVAssetExportSession.determineCompatibility(ofExportPreset: AVAssetExportPresetPassthrough, with: videoAsset, outputFileType: AVFileType.m4a, completionHandler: { result in
            guard result else {
                print("Video file cannot be converted to .m4a format.")
                return
            }
        })
        
        // Create a composition
        let composition = AVMutableComposition()
        do {
            // Creat an AVAsset from the video's sourceURL
            let asset = AVURLAsset(url: sourceURL)
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return }
            guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            self.state = .extractedAudio(.failure(.error("Error extracting audio from video file: \(error.localizedDescription)")))
        }

        // Get URL for output
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "extracted-audio.m4a")
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(atPath: outputURL.path)
        }

        // Create an export session
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputURL

        // Export file
        exportSession.exportAsynchronously {
            guard case exportSession.status = AVAssetExportSession.Status.completed else { return }

            guard let outputURL = exportSession.outputURL else { return }
            print("Extracted audio file has URL path: \(outputURL)")
            self.state = .extractedAudio(.success(outputURL))
        }
        return
    }

    // Convert .m4a file to .wav format
    func convertAudio(forFile inputURL: URL) {
        let outputURL: URL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
        
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil

        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()

        ExtAudioFileOpenURL(inputURL as CFURL, &sourceFile)

        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))

        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)

        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Status 1 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Status 2 in convertAudio: \(error.description)")

        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Status 3 in convertAudio: \(error.description)")

        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0

        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0

            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }

            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Status 4 in convertAudio: \(error.description)")

            if(numFrames == 0){
                error = noErr;
                break;
            }

            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Status 5 in convertAudio: \(error.description)")
        }

        error = ExtAudioFileDispose(destinationFile!)
        print("Status 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Status 7 in convertAudio: \(error.description)")
        
        if error == 0 {
            self.state = .convertedAudio(.success(outputURL))
        }
        else {
            self.state = .convertedAudio(.failure(.error("Error converting audio to .wav format: \(error.description)")))
        }
    }

    // Upload audio to Google Cloud Storage where a Firebase transcription function will be triggered
    func uploadAudio(fromFile audioURL: URL) {
        
        // Assign a random identifier to be used in the bucket and reference the file in the bucket
        let randomID = UUID.init().uuidString
        let uploadRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-audio/\(randomID).wav")
        
        // Create file metadata
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "audio/wav"
        
        // Do a PUT request to upload the file and check for errors
        print("Uploading audio to the cloud...")
        uploadRef.putFile(from: audioURL, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                self.state = .uploadedAudio(.failure(.error("Error uploading audio file! \(error.localizedDescription)")))
            }
            else {
                print("PUT is complete. Successful response from server is: \(downloadMetadata!)")
                self.state = .uploadedAudio(.success((uploadRef, randomID)))
            }
        }
        
    }

    // Download captions file from Google Cloud Storage
    func downloadCaptions(withID fileID: String) {
        var repeatFlag = true
        
        // Do a GET request to download the captions file and check for errors
        let storageRef = Storage.storage().reference(forURL: "gs://opencaptionsmaker.appspot.com/temp-captions/\(fileID).json")
        
        repeat {
            storageRef.getData(maxSize: 1024 * 1024) { (data, error) in
                
                // If there is an error in downloading the file
                if let error = error {
                    self.state = .downloadedJSON(.failure(.error("Error downloading captions file! \(error.localizedDescription)")))
                }
                else {
                    print("Captions file succesfully downloaded.")
                    let decoder = JSONDecoder()
                    do {
                        // Parse downloaded response as JSON
                        let result = try decoder.decode(JSONResult.self, from: data!)
                        let captions = result.transcriptions
                        print("Successfully parsed JSON.")
                        self.state = .downloadedJSON(.success((storageRef, captions)))
                        repeatFlag = false
                    } catch {
                        self.state = .downloadedJSON(.failure(.error("Error parsing JSON! \(error.localizedDescription)")))
                    }
                }
            }
            sleep(5)  // Polling period
        } while ( repeatFlag == true )
    }

    // Delete temporary files from bucket in Google Cloud Storage
    func deleteTempFiles(audio audioRef: StorageReference, json jsonRef: StorageReference) {
        
        audioRef.delete { error in
            if let error = error {
                self.state = .deletedTemp(.failure(.error("Error deleting audio file from Google Cloud Storage: \(error.localizedDescription)")))
            } else {
                self.state = .deletedTemp(.success("Successfully deleted audio file from Google Cloud Storage."))
            }
        }
        
        jsonRef.delete { error in
            if let error = error {
                self.state = .deletedTemp(.failure(.error("Error deleting JSON file from Google Cloud Storage: \(error.localizedDescription)")))
            } else {
                self.state = .deletedTemp(.success("Successfully deleted JSON file from Google Cloud Storage."))
            }
        }
    }
}

//// Generates captions by using a transcription service
//func _generateCaptions(forFile videoURL: URL) -> Void {
//
//    // Extract audio from video file and asynchronously return result in a closure
//    extractAudio(fromVideoFile: videoURL) { m4aURL, error in
//        if m4aURL != nil {
//
//            // Convert .m4a file to .wav format
//            let wavURL = URL(fileURLWithPath: NSTemporaryDirectory() + "converted-audio.wav")
//            convertM4AToWAV(inputURL: m4aURL!, outputURL: wavURL)
//
//            // Upload audio to Google Cloud Storage
//            uploadAudio(withURL: wavURL) { audioRef, fileID, error in
//                if fileID != nil {
//
//                    // Download captions file from Google Cloud Storage by short polling the server
//                    do { sleep(10) }  // TODO: Make this a websockets callback to the Firebase DB
//                    downloadCaptions(withFileID: fileID!) { captionData, error in
//                        if captionData != nil {
//                            self.captions = captionData!
//                            print(self.captions)
//                            //deleteAudio(withStorageRef: audioRef!) //FIXME: This is messing up the upload step (multithread issue!)
//                        } else { self.captions = [] }
//
//                        return
//                    }
//                }
//            }
//        }
//    }
//}