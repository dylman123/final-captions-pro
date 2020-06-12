//
//  FontPicker.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 12/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine

struct FontPicker: NSViewRepresentable {
    //@EnvironmentObject var app: AppState
    //@Binding var selectedFont: NSFont
    
//    class Coordinator: NSObject {
//        var embedded: FontPicker
//        var subscription: AnyCancellable?
//        var app: AppState
//
//        init(_ embedded: FontPicker, environmentObject app: AppState) {
//            self.embedded = embedded
//            self.app = app
//        }
//
//        // Observe KVO compliant color property on NSFontPanel object.
//        // Update the selectedColor property on EmbeddedColorWell as needed.
//        func changeFont(fontPanel: NSFontPanel) -> Void {
//            subscription = fontPanel
//                .publisher(for: \.isEnabled , options: .new)
//                .sink { isEnabled in
//                    if isEnabled {
//                        DispatchQueue.main.async {
//                            self.embedded.selectedFont = font(selectedFont)
//                            self.app.captions[self.app.selectedIndex].style.font = font
//                        }
//                    }
//                }
//        }
//    }
//
//    func makeCoordinator() -> FontPicker.Coordinator {
//        Coordinator(self, environmentObject: app)
//    }
    
    func makeNSView(context: Context) -> NSFontPanel {
        let fontPanel = NSFontPanel(contentViewController: NSViewController(coder: NSCoder())!)
        //context.coordinator.changeFont(fontPanel: fontPanel)
        return fontPanel
    }
    
    func updateNSView(_ nsView: NSFontPanel, context: Context) {
        //nsView.setPanelFont(selectedFont, isMultiple: false)
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker()//selectedFont: .constant(NSFont(name: "Arial", size: 60)!))
    }
}
