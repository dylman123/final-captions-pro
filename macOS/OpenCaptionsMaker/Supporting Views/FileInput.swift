//
//  FileInput.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 20/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import SwiftUI
import AppKit

struct FileInput: View {
    
    // Write data back to model
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
    
    var body: some View {
        
        Button(action: {
            
            let video: URL? = self.openFileDialog()
            
            if video != nil {
                print("Selected video file has URL path: \(String(describing: video!))")
                
                // Close the FileInput view
                self.showFileInput.toggle()
                self.presentationMode.wrappedValue.dismiss()
                
                // Generate captions
                generateCaptions(forFile: video!)
            }
            else {
                print("No file was selected.")
            }
        }) {
            Text("Select video from file")
        }
        
    }
}

struct FileInput_Previews: PreviewProvider {
    
    static var previews: some View {
        FileInput(showFileInput: true)
    }
}