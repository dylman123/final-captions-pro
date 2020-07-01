//
//  ContentView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 14/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
import SwiftUI

struct ContentView: View {
    
    // Set window sizes
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    // To refresh the UI when app state changes
    @EnvironmentObject var app: AppState
    @State private var showFileInput: Bool = false
    @State private var showExportLabel: Bool = false
    
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
        
        // Window view for edit screen
        HStack {
            
            VStack {
                //Text("State: \(stateLabel)")  // uncomment to test state in app
                
                // Video player
                if app.videoURL != nil {
                    VideoPlayer(url: app.videoURL)
                } else { EmptyView() }
            }
            .buttonStyle(BorderlessButtonStyle())
            .frame(width: self.windowWidth*0.6, height: self.windowHeight*0.8)
            .padding(.horizontal, 25)
            
            VStack {
                
                // Finish review button
                HStack {
                    Spacer()
                    if showExportLabel { Text("Export to Final Cut Pro") }
                    Button(action: {
                        finishReview(inAppState: self.app, andSaveFileAs: URL(fileURLWithPath: "/Users/dylanklein/Desktop/OpenCaptionsMaker/test.fcpxml"))
                    },
                    label: {
                        Image(systemName: "greaterthan").onHover(perform: { _ in self.showExportLabel.toggle() })
                    })
                }
                .offset(y: 20)
                
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
                FileSelector(showFileInput: self.showFileInput)
                    .padding()
                    .frame(width: self.windowWidth*0.2, height: self.windowHeight*0.2)
                    .environmentObject(self.app)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
