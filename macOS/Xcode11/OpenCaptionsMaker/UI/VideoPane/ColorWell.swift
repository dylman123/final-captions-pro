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
    @Binding var selectedColor: NSColor
    
    class Coordinator: NSObject {
        var embedded: ColorWell
        var subscription: AnyCancellable?

        init(_ embedded: ColorWell) {
            self.embedded = embedded
        }
        
        // Observe KVO compliant color property on NSColorWell object.
        // Update the selectedColor property on EmbeddedColorWell as needed.
        func changeColor(colorWell: NSColorWell) -> Void {
            subscription = colorWell
                .publisher(for: \.color, options: .new)
                .sink { color in
                    DispatchQueue.main.async { [weak self] in
                        self?.embedded.selectedColor = color
                    }
                }
        }
    }
    
    func makeCoordinator() -> ColorWell.Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSColorWell {
        let colorWell = NSColorWell(frame: .zero)
        context.coordinator.changeColor(colorWell: colorWell)
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
