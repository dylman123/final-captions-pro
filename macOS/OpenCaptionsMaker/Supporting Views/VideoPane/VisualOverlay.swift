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
//    private var offset: CGSize {
//        let w = CGFloat(self.xPos)
//        let h = CGFloat(self.yPos)
//        return CGSize(width: w, height: h)
//    }
    @State private var offset: CGSize = .zero
    @State private var translation: CGSize = .zero
    //private var xPos: CGFloat = 0.0
    //private var yPos: CGFloat = 200.0
    
    var body: some View {
        
        ZStack {
            // Color.clear is undetected by onTapGesture
            Rectangle().fill(Color.blue.opacity(0.001))
            
            Text(caption.text)
                //.offset(x: CGFloat(xPos), y: CGFloat(yPos))
                //.offset(x: CGFloat(caption.style.xPos), y: CGFloat(caption.style.yPos))
                .offset(x: self.offset.width, y: self.offset.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            self.translation = gesture.translation
                            //self.xPos = Float(gesture.translation.width)
                            //self.yPos = Float(gesture.translation.height)
                        }

                        .onEnded { _ in
                            self.offset = self.translation
                            //self.offset = gesture.predictedEndTranslation
//                            self.app.captions[self.index].style.xPos = Float(self.offset.width)
//                            self.app.captions[self.index].style.yPos = Float(self.offset.height)
//                            print("x: ", self.app.captions[self.index].style.xPos, "y: ", self.app.captions[self.index].style.yPos)
//                            self.offset.width = CGFloat(self.caption.style.xPos)
//                            self.offset.height = CGFloat(self.caption.style.yPos)
//                            print("X: ", self.caption.style.xPos, "Y: ", self.caption.style.yPos)
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
