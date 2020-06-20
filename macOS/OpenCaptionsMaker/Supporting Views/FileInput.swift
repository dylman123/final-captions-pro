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
    
    @ObservedObject var userAPI = CaptionMaker()
    @State var audioRef: StorageReference?
    @State var jsonRef: StorageReference?
    
    func closeView() {
        DispatchQueue.main.async {
            self.showFileInput.toggle()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var progressView: AnyView {
        var status = ""
        print("State: ", userAPI.state)
        switch userAPI.state {
            
        case .idle:
            return AnyView(
                Button(action: {
                    let video: URL? = self.openFileDialog()
                    if video != nil {
                        print("Selected video file has URL path: \(String(describing: video!))")
                        self.app.videoURL = video!
                        self.userAPI.generateCaptions()
                    }
                    else { print("No file was selected.") }
                }) { Text("Select video from file") }
            )
            
        case .videoSelected:
            userAPI.extractAudio(fromFile: app.videoURL!)
            status = "Extracting audio from video..."
            return AnyView(Text(status))
            
        case .extractedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription))
            case .success(let m4aURL):
                userAPI.convertAudio(forFile: m4aURL)
                status = "Coverting audio to .wav format..."
                return AnyView(Text(status))
            }
            
        case .convertedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription))
            case .success(let wavURL):
                userAPI.uploadAudio(fromFile: wavURL)
                status = "Uploading audio to server..."
                return AnyView(Text(status))
            }
            
        case .uploadedAudio(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription))
            case .success(let (ref, id)):
                audioRef = ref
                userAPI.downloadCaptions(withID: id)
                status = "Transcribing audio..."
                return AnyView(Text(status))
            }
            
        case .downloadedJSON(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription))
            case .success(let (ref, captions)):
                jsonRef = ref
                app.captions = captions
                userAPI.deleteTempFiles(audio: audioRef!, json: jsonRef!)
                status = "Downloaded captions! Deleting temp server files..."
                return AnyView(Text(status))
            }
            
        case .deletedTemp(let result):
            switch result {
            case .failure(let error):
                return AnyView(Text(error.localizedDescription))
            case .success:
                closeView()
                return AnyView(EmptyView())
            }
        }
    }
    
    var body: some View {
        progressView
    }
}

struct FileInput_Previews: PreviewProvider {
    
    static var previews: some View {
        FileInput(showFileInput: true)
    }
}
