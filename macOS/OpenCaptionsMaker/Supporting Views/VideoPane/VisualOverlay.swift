//
//  VisualOverlay.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct VisualOverlay: View {
    
    @EnvironmentObject var state: AppState
    
    private var text: String {
        let captions = self.state.captions
        let index = self.state.selectedIndex
        return captions[index].text
    }
    
    private var xPos: CGFloat = 0.0
    private var yPos: CGFloat = 200.0
    
    var body: some View {
        
        ZStack {
            // Color.clear is undetected by onTapGesture
            Rectangle().fill(Color.blue.opacity(0.001))
            
            Text(text)
            .offset(x: xPos, y: yPos)
                .onDrag({ NSItemProvider()})  // this is currently crashing the app
        }
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay()
        .environmentObject(AppState())
    }
}
