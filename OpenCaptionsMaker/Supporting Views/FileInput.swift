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
    
    @State private var isPressed: Bool = false
    let dialog: NSOpenPanel = NSOpenPanel()
    
    var body: some View {
        
        Button(action: {
            self.isPressed.toggle()
            self.dialog.runModal()
        }) {
            Text("Select video from file")
        }
        
    }
}

struct FileInput_Previews: PreviewProvider {
    static var previews: some View {
        FileInput()
    }
}
