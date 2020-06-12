//
//  ColorWell.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 12/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine

struct ColorWell: NSViewRepresentable {
    @EnvironmentObject var app: AppState
    @Binding var selectedColor: NSColor
    
    class Coordinator: NSObject {
        var embedded: ColorWell
        var subscription: AnyCancellable?
        var app: AppState

        init(_ embedded: ColorWell, environmentObject app: AppState) {
            self.embedded = embedded
            self.app = app
        }
        
        // Observe KVO compliant color property on NSColorWell object.
        // Update the selectedColor property on EmbeddedColorWell as needed.
        func changeColor(colorWell: NSColorWell) -> Void {
            //var savedColor: NSColor?
            subscription = colorWell
                .publisher(for: \.color, options: .new)
                .sink { color in
                    DispatchQueue.main.async {
                        self.embedded.selectedColor = color
                        self.app.captions[self.app.selectedIndex].style.color = color
                        //savedColor = color
                    }
                }
        }
    }
    
    func makeCoordinator() -> ColorWell.Coordinator {
        Coordinator(self, environmentObject: app)
    }
    
    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell(frame: .zero)
        context.coordinator.changeColor(colorWell: colorWell)
        //if savedColor != nil { app.captions[app.selectedIndex].style.color = savedColor! }
        return colorWell
    }
    
    func updateNSView(_ nsView: NSColorWell, context: Context) {
        nsView.color = selectedColor
    }
}

struct ColorWell_Previews: PreviewProvider {
    static var previews: some View {
        ColorWell(selectedColor: .constant(.red))
    }
}
