//
//  ContentView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 14/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import SwiftUI

struct ContentView: View {
        
    // To refresh the UI when app state changes
    @EnvironmentObject var app: AppState
    @State private var showFileInput: Bool = false
    
    // Test video
    var testVideo: URL? {
        guard let url = Bundle.main.url(forResource: "RAW-long", withExtension: "m4v") else { print("Couldn't load test video"); return nil }
        return url
    }
    
    var stateLabel: String {
        switch app.mode {
        case .play: return "Play"
        case .pause: return "Pause"
        case .edit: return "Edit"
        case .editStartTime: return "Edit Start Time"
        case .editEndTime: return "Edit End Time"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            // Set window sizes
            let windowWidth = geometry.size.width
            let windowHeight = geometry.size.height

            HStack {
                
                VStack {
                    // Video player
                    if app.videoURL != nil {
                        VideoPlayer(url: app.videoURL)
                    } else { EmptyView() }
                }
                .buttonStyle(BorderlessButtonStyle())
                .frame(width: windowWidth*0.6, height: windowHeight*0.8)
                .padding(.horizontal, 25)
                
                VStack {
                    ExportButton()
                    Spacer()
                    // Captions list
                    Headers()
                    CaptionList()
                        .frame(height: windowHeight*0.8)
                    
                    Spacer()
                }
                .frame(width: windowWidth/3)
                .padding(.horizontal, 25)
            }
            .frame(width: windowWidth, height: windowHeight)
            .sheet(isPresented: $showFileInput, content: {
                if showFileInput {
                    // Shows file dialog button
                    FileSelector(showFileInput: showFileInput)
                        .padding()
                        .frame(width: windowWidth*0.2, height: windowHeight*0.2)
                        .environmentObject(app)
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
