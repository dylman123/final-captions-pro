////
////  ColorWell.swift
////  OpenCaptionsMaker
////
////  Created by Dylan Klein on 11/6/20.
////  Copyright © 2020 Dylan Klein. All rights reserved.
////
//
//import SwiftUI
//
////  User to pick a color from  well
//struct ColorWell: NSViewRepresentable {
//
//    @State private var color = defaultStyle().color
//
//    class Coordinator {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator()
//    }
//
//    func makeNSView(context: Context) -> NSColorWell {
//        let well = NSColorWell()
//        print("makeNSview color: \(Color(well.color))")
//        publishToVisualOverlay(color: Color(well.color))
//        //well.delegate = context.coordinator
//        return well
//    }
//
//    func updateNSView(_ nsView: NSColorWell, context: Context) {
//        let refreshed = Color(nsView.color)
//        if refreshed != color {
//            color = refreshed
//            print("updateNSview color: \(color)")
//            publishToVisualOverlay(color: color)
//        }
//    }
//}
//
//struct ColorWell_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorWell()
//    }
//}
//
//func publishToTextStyler(color: NSColor) -> Void {
//    NotificationCenter.default.post(name: .updateColor, object: color)
//}
