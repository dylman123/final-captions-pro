//
//  ContentView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 14/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import SwiftUI
//import AVFoundation
import AVKit

struct ContentView: View {
    
    //Set window sizes
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    @State private var showFileInput: Bool = false
    @State private var showProgressBar: Bool = false
    
    var body: some View {
        
        // Window view for edit screen
        HStack {

            //Video player
            //FakeVideoExample()
            //VideoPlayer(url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
            VideoPlayer(url: "file:///Users/dylanklein/Documents/MyProjects/SubtitleGenerator/Git/automatic-subtitle-generator/inputs/RAW-long.m4v")
            //TestVideoView()
            //PlayerView()
                .frame(width: self.windowWidth*0.6, height: self.windowHeight*0.8)
                .padding(.horizontal, 25)
                .buttonStyle(BorderlessButtonStyle())
            
            VStack {
                
                // Finish review button
                HStack {
                    
                    Spacer()
                    Button(action: {
                        finishReview(andSaveFileAs: URL(fileURLWithPath: "/Users/dylanklein/Desktop/OpenCaptionsMaker/test.fcpxml"))
                    },
                    label: {
                        IconView("NSGoForwardTemplate")
                    })
                    .offset(y: 20)
                }
                
                Spacer()
                
                // Captions list
                Headers()
                CaptionList()
                    .frame(height: self.windowHeight*0.8)
                
                Spacer()
            }
            .frame(width: self.windowWidth/3)
            .padding(.horizontal, 25)
        }
        .frame(width: self.windowWidth, height: self.windowHeight)
        .sheet(isPresented: $showFileInput, content: {
            if self.showFileInput {
                // Shows file dialog button
                FileInput(showFileInput: self.showFileInput)
                    .padding()
                    .frame(width: self.windowWidth*0.2, height: self.windowHeight*0.2)
            }
            else if self.showProgressBar {
                // Progress bar whilst tasks are loading
                ProgressView()
                    .padding()
                    .frame(width: self.windowWidth*0.2, height: self.windowHeight*0.2)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
