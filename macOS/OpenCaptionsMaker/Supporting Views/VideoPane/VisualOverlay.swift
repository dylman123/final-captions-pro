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
    private var style: Style { caption.style }
    //private var position: CGSize { getCaptionStylePosition(style.xPos, style.xPos) }
    @State private var position: CGSize = .zero
    @State private var offset: CGSize = .zero
    
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat) {
        if self.offset.width >= maxWidth { self.offset.width = maxWidth }
        if self.offset.width <= -maxWidth { self.offset.width = -maxWidth }
        if self.offset.height >= maxHeight { self.offset.height = maxHeight }
        if self.offset.height <= -maxHeight { self.offset.height = -maxHeight }
    }
    
//    func getCaptionStylePosition(_ xPosStateful: Float, _ yPosStateful: Float) -> CGSize {
//        let xPos = CGFloat(xPosStateful)
//        let yPos = CGFloat(yPosStateful)
//        return CGSize(width: xPos, height: yPos)
//    }
    
    init(xPos x0: Float, yPos y0: Float) {
//        let (xPos, yPos) = getCaptionStylePosition(initialCoords: (x0, y0))
//        let xPos = CGFloat(x0)
//        let yPos = CGFloat(y0)
//        self.offset = self.position
    }
    
    var body: some View {
        
        ZStack {
            // Color.clear is undetected by onTapGesture
            Rectangle().fill(Color.blue.opacity(0.001))
            
            Text(caption.text)
                .offset(x: self.offset.width, y: self.offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            
                            // Break down coords into 2D components
                            let xPos = self.position.width
                            let yPos = self.position.height
                            
                            // Try move caption
                            self.offset.width = xPos + gesture.translation.width
                            self.offset.height = yPos + gesture.translation.height
                            
                            // Keep caption within video frame bounds
                            self.restrictDrag(maxWidth: 400, maxHeight: 300)
                        }

                        .onEnded { _ in
                            
                            // Save positional coords
                            self.position = self.offset
                            self.style.xPos = Float(self.offset.width)
                            self.style.yPos = Float(self.offset.height)
                            
                            print("\(self.caption)\n\(self.caption.style.xPos), \(self.caption.style.yPos)\n")
                        }
                )
        }
        .onTapGesture {
            if self.app.mode == .play { self.app.transition(to: .pause) }
            else { self.app.transition(to: .play) }
        }
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay(xPos: 0, yPos: 200)
        .environmentObject(AppState())
    }
}
