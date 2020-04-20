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
    
    // A variable to track the selected row
    @State private var selectedCaption: Caption?
    
    var body: some View {
        
        // Window view for edit screen
        HStack {
            
            //Video player
            //FakeVideoExample()
            VideoPlayer(url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
                .frame(width: windowWidth*0.6, height: windowHeight*0.6)
            .padding(.horizontal, 25)

            // Captions list
            VStack {
                Headers()
                CaptionList(selectedCaption: $selectedCaption)
                .environmentObject(UserData())
            }
            .frame(width: windowWidth/3, height: windowHeight*0.8)
            .padding(.horizontal, 25)
        }
        .frame(width: windowWidth, height: windowHeight)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
