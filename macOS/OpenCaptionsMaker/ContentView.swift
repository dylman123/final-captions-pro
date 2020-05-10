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
    
    @EnvironmentObject var userData: UserData
    @State private var selectedCaption: Caption?  //  To track the selected row
    
    var body: some View {
        
        // Window view for edit screen
        HStack {

            //Video player
            //FakeVideoExample()
            //VideoPlayer(url: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")
            TestVideoView()
                .frame(width: self.windowWidth*0.6, height: self.windowHeight*0.8)
                .padding(.horizontal, 25)

            VStack {
                
                // Finish review button
                HStack {
                    
                    Spacer()
                    Button(action: {
                        self.userData._finishReview(andSaveFileAs: URL(fileURLWithPath: "/Users/dylanklein/Desktop/OpenCaptionsMaker/test.fcpxml"))
                    },
                    label: {
                        IconView("NSGoForwardTemplate")
                    })
                    .offset(y: 20)
                }
                
                Spacer()
                
                // Captions list
                Headers()
                CaptionList(selectedCaption: $selectedCaption)
                .environmentObject(self.userData)
                .frame(height: self.windowHeight*0.8)
                
                Spacer()
            }
            .frame(width: self.windowWidth/3)
            .padding(.horizontal, 25)
        }
        .frame(width: self.windowWidth, height: self.windowHeight)
        .sheet(isPresented: $userData.showTaskPane, content: {
            if self.userData.showFileInput {
                
                // Shows file dialog button
                FileInput()
                    .environmentObject(self.userData)
                    .padding()
                    .frame(width: self.windowWidth*0.2, height: self.windowHeight*0.2)
            }
            else if self.userData.showProgressBar {
                
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
        ContentView().environmentObject(UserData())
    }
}
