//
//  FileInput.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 20/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import SwiftUI
import AppKit
import Firebase

struct FileInput: View {
    
    // Write data back to model
    @EnvironmentObject var app: AppState
    @State var showFileInput: Bool
    
    // To show/hide the FileInput view
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    // Function to prompt user to import a video file
    func openFileDialog() -> URL? {
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["m4v", "mp4", "mov"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url  // Pathname of the file
            if (result != nil) {
                let path: URL = result!.absoluteURL
                return path  // path contains the file path e.g
            }
        } else {
            return nil  // User clicked on "Cancel"
        }
        return nil
    }
    
    // To manage the API-based transcription process
    @ObservedObject var userAPI = Transcriber()
    
    private var StatusView: AnyView {
        var status = ""
        print(userAPI.state)
        switch userAPI.state {
            
        case .idle:
            return AnyView(
                Button(action: {
                    let video: URL? = self.openFileDialog()
                    if video != nil {
                        print("Selected video file has URL path: \(String(describing: video!))")
                        self.userAPI.generateCaptions(forFile: video!)
                    }
                    else { print("No file was selected.") }
                }) { Text("Select video from file") }
            )
            
        case .selectedVideo(let result):
            switch result {
            case .failure: return AnyView(EmptyView())
            case .success(let url):
                userAPI.extractAudio(fromFile: url)
                status = "Extracting audio from video..."
                return AnyView(VStack {
                    Text(status).multilineTextAlignment(.center)
                })
            }
            
        case .extractedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription).multilineTextAlignment(.center))
            case .success(let m4aURL):
                userAPI.convertAudio(forFile: m4aURL)
                status = "Coverting audio to .wav format..."
                return AnyView(VStack {
                    Text(status).multilineTextAlignment(.center)
                    ProgressView()
                })
            }
            
        case .convertedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription).multilineTextAlignment(.center))
            case .success(let wavURL):
                userAPI.uploadAudio(fromFile: wavURL)
                status = "Uploading audio to server..."
                return AnyView(VStack {
                    Text(status).multilineTextAlignment(.center)
                    ProgressView()
                })
            }
            
        case .uploadedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription).multilineTextAlignment(.center))
            case .success(let id):
                userAPI.downloadCaptions(withID: id)
                status = "Transcribing audio. This may take several minutes..."
                return AnyView(VStack {
                    Text(status).multilineTextAlignment(.center)
                    ProgressView()
                })
            }
            
        case .downloadedJSON(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription).multilineTextAlignment(.center))
            case .success:
                userAPI.deleteTempFiles()
                status = "Downloaded captions! Deleting temp server files..."
                return AnyView(VStack {
                    Text(status).multilineTextAlignment(.center)
                    ProgressView()
                })
            }
            
        case .deletedTemp(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription).multilineTextAlignment(.center))
            case .success:
                closeView()
                return AnyView(EmptyView())
            }
        }
    }
    
    func closeView() {
        DispatchQueue.main.async {
            self.app.videoURL = self.userAPI.video!
            self.app.captions = self.userAPI.captions!
            self.showFileInput.toggle()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        StatusView
    }
}

struct FileInput_Previews: PreviewProvider {
    
    static var previews: some View {
        FileInput(showFileInput: true)
    }
}
