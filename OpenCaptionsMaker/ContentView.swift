//
//  ContentView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 14/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    //Set window sizes
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    

    @State private var selectedCaption: Caption?  //  To track the selected row
    @State private var display: Bool = true  //  To display overlaying file input sheet
    
    var body: some View {
        
        // Window view for edit screen
        HStack {

            VStack {
                //Video player
                //FakeVideoExample()
                VideoPlayer(url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
                    .frame(width: self.windowWidth*0.6, height: self.windowHeight*0.6)
                    .padding(.horizontal, 25)
            }

            // Captions list
            VStack {
                Headers()
                CaptionList(selectedCaption: $selectedCaption)
                .environmentObject(CaptionData())
            }
            .frame(width: self.windowWidth/3, height: self.windowHeight*0.8)
            .padding(.horizontal, 25)
        }
        .frame(width: self.windowWidth, height: self.windowHeight)
        .sheet(isPresented: $display, content: {
            FileInput()
                .padding()
                .frame(width: self.windowWidth*0.2, height: self.windowHeight*0.2)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
