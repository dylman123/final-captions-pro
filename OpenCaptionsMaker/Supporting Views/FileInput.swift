//
//  FileInput.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 20/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine
import AppKit

struct FileInput: View {
    
    // Write data back to model
    @EnvironmentObject var userData: UserData
    
    // To show/hide the FileInput view
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
    // Function to prompt user to import a video file
    func openFileDialog() -> String? {
        let dialog = NSOpenPanel()
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedFileTypes = ["m4v", "mp4", "mov"]
        
        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url  // Pathname of the file
            if (result != nil) {
                let path: String = result!.path
                return path// path contains the file path e.g
            }
        } else {
            return nil  // User clicked on "Cancel"
        }
        return nil
    }
    
    var body: some View {
        
        Button(action: {
            let videoPath: String? = self.openFileDialog()
            print("Selected file has path: \(videoPath ?? "None")")
            if videoPath != nil {
                // Close the FileInput view
                self.userData.displayFileInput.toggle()
                self.presentationMode.wrappedValue.dismiss()
            }

        }) {
            Text("Select video from file")
        }
        
    }
}

struct FileInput_Previews: PreviewProvider {
    
    static var previews: some View {
        FileInput().environmentObject(UserData())
    }
}
