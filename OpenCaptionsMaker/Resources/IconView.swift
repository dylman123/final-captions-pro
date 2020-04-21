//
//  MySVGView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//  Using UIKit Icon elements

import SwiftUI

struct IconView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSImageView {
        let icon = NSImageView(image: NSImage(imageLiteralResourceName: "NSAddTemplate"))
        return icon
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
    }
    
}

struct IconView_Previews: PreviewProvider {
    static var previews: some View {
        IconView()
    }
}
