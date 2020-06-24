//
//  ProgressView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 24/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

//  Progress indicator whilst waiting for API response
struct ProgressView: NSViewRepresentable {
  
    func makeNSView(context: Context) -> NSProgressIndicator {
        let progress = NSProgressIndicator()
        progress.isIndeterminate = true
        progress.style = .spinning
        progress.startAnimation(.none)
        return progress
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
