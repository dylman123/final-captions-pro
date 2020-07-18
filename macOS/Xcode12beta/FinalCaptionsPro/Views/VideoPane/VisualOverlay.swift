//
//  VisualOverlay.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct VisualOverlay: View {
    
    @EnvironmentObject var app: AppState
    @Binding var caption: Caption
    
    // Consider caption timings when displaying caption text
    var displayText: Bool {
        guard app.mode == .play else { return true }  // always display during non-play mode
        guard app.selectedIndex != app.captions.count-1 else { return true }  // to avoid index out of range error
        let timestamp = app.videoPos * app.videoDuration
        // Current caption's timings
        let startTime = Double(caption.start)
        let endTime = Double(caption.end)
        // Compare to next caption to find a gap
        //let nextCaption = app.captions[app.selectedIndex+1]
        //let nextStart = Double(nextCaption.start)
        // Display logic
        if ( timestamp >= startTime ) && ( timestamp <= endTime ) { return true }
        //else if (nextStart - endTime < 0.2) { return true }
        else { return false }  // only disappear if pause is over 0.2 seconds
    }
    
    let stylerBarThickness: CGFloat = 35
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                if app.mode != .play {
                    Styler(style: $caption.style, barThickness: stylerBarThickness)
                }
                else {
                    // Need an empty rectangle here to maintain text's vertical pos in VStack
                    Rectangle()
                        .fill(Color.blue.opacity(0.001))  // transparent
                        .frame(height: stylerBarThickness)
                }
                
                ZStack {
                    
                    // Color.clear is undetected by onTapGesture
                    Rectangle()
                        .fill(Color.blue.opacity(0.001))  // transparent
                        .onTapGesture {
                            if app.mode == .play { app.transition(to: .pause) }
                            else { app.transition(to: .play) }
                        }
                    
                    if displayText {
                        
                        // Caption text is displayed with all its attributes
                        DisplayedText (
                            text: caption.text,
                            font: caption.style.font,
                            size: caption.style.size,
                            color: caption.style.color,
                            position: $caption.style.position,
                            alignment: caption.style.alignment,
                            bold: caption.style.bold,
                            italic: caption.style.italic,
                            underline: caption.style.underline,
                            geometry: geometry
                        )
                    }
                }
            }
        }
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay(caption: .constant(Caption()))
        .environmentObject(AppState())
        .frame(height: 500)
    }
}
