//
//  AppKitElements.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//  Using AppKit elements

import SwiftUI

//  Generic struct to use any builtin icons
struct IconView: NSViewRepresentable {
    
    let systemName: String
    
    init(_ systemName: String) {
        self.systemName = systemName
    }
    
    func makeNSView(context: Context) -> NSImageView {
        let icon = NSImageView(image: NSImage(imageLiteralResourceName: systemName))
        return icon
    }
    
    func updateNSView(_ nsView: NSImageView, context: Context) {
    }
    
}

//  User to pick a color from  well
struct ColorWellView: NSViewRepresentable {
  
    class Coordinator {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> NSColorWell {
        let well = NSColorWell()
        //well.delegate = context.coordinator
        return well
    }
    
    func updateNSView(_ nsView: NSColorWell, context: Context) {
    }
}

//  Progress indicator whilst waiting for API response
struct ProgressView: NSViewRepresentable {
  
    func makeNSView(context: Context) -> NSProgressIndicator {
        let progress = NSProgressIndicator()
        return progress
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
    }
}

struct PageController: NSViewControllerRepresentable {
    
    class Coordinator: NSObject, NSPageControllerDelegate {
        var parent: PageController
        
        init(_ parent: PageController) {
            self.parent = parent
        }
        
        func nsPageController(_ picker: NSPageController, info: [NSPageController.InfoKey : Any]) {
            if let nsView = info[.view] as? NSView {
                parent.view = nsView
            }
            
            parent.presentationMode.wrappedvalue.dismiss()
        }
    }
    
    @Binding var view: NSView?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSViewController(context: NSViewControllerRepresentableContext<PageController>) -> NSPageController {
        let ctrl = NSPageController()
        ctrl.delegate = context.coordinator as NSPageControllerDelegate
        return ctrl
    }
    
    func updateNSViewController(_ nsPageController: NSPageController, context: NSViewControllerRepresentableContext<PageController>) {
    }
    
}

struct AppKitElements_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
