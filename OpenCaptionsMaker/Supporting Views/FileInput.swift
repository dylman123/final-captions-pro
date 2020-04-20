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
    
    @State private var val: Double = 0
    
    var body: some View {
        
        func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<FileInput>) {
            // This function gets called if the bindings change, which could be useful if
            // you need to respond to external changes, but we don't in this example
        }
        
        func makeNSView(context: NSViewRepresentableContext<FileInput>) -> NSView {
            let nsView = NSDocumentController()
            
            return nsView
        }
        
    }
}

struct FileInput_Previews: PreviewProvider {
    static var previews: some View {
        FileInput()
    }
}
