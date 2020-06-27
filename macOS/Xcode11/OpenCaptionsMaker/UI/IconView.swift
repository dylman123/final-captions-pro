//
//  IconView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//  Using AppKit elements

import SwiftUI

//  Generic struct to use any builtin icons
struct IconView: NSViewRepresentable {
    
    let systemName: String
    
    init(_ systemName: String) {
        self.systemName = systemName
    }
    
    func makeNSView(context: Context) -> NSImageView {
        let icon = NSImageView(image: NSImage(imageLiteralResourceName: systemName))
        return icon
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
    }
    
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView("")
    }
}
