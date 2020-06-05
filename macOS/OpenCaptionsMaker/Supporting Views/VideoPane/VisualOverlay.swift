//
//  VisualOverlay.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct VisualOverlay: View {
    
    @EnvironmentObject var app: AppState
    private var index: Int { app.selectedIndex }
    private var caption: Caption { app.captions[index] }

    
    @State var xPos: Float
    @State var yPos: Float
    @State private var offset: CGSize = .zero
    @State private var position: CGSize = .zero
    //private var xPos: CGFloat = 0.0
    //private var yPos: CGFloat = 200.0
    
    var body: some View {
        
        ZStack {
            // Color.clear is undetected by onTapGesture
            Rectangle().fill(Color.blue.opacity(0.001))
            
            Text(caption.text)
                .offset(x: self.offset.width, y: self.offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.offset.width = self.position.width + gesture.translation.width
                            self.offset.height = self.position.height + gesture.translation.height
                        }

                        .onEnded { _ in
                            self.position = self.offset
                        }
                )
        }
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay(xPos: 0.0, yPos: 200.0)
        .environmentObject(AppState())
    }
}
