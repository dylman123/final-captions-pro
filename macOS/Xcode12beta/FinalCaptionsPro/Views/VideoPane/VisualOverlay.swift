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
        guard app.mode == .play else { return true }  // do not display during play mode
        let timestamp = app.videoPos * app.videoDuration
        let startTime = Double(caption.start)
        let endTime = Double(caption.end)
        if ( timestamp >= startTime ) && ( timestamp < endTime ) { return true }
        else { return false }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                // Color.clear is undetected by onTapGesture
                Rectangle().fill(Color.blue.opacity(0.001))
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
                
                // Style editor
                if app.mode != .play { Styler(style: $caption.style).offset(y: -290) }
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
