//
//  VisualOverlay.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 4/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct VisualOverlay: View {
    
    @EnvironmentObject var app: AppState
    //private var index: Int { app.selectedIndex }
    @Binding var caption: Caption //{ app.captions[index] }
    private var style: Style { caption.style }
    @State private var localPos: CGSize = defaultStyle().position

//    @State private var font: String = defaultStyle().font
//    @State private var size: CGFloat = defaultStyle().size
//    @State private var color: NSColor = defaultStyle().color
//    @State private var position: CGSize = defaultStyle().position
//    @State private var alignment: TextAlignment = defaultStyle().alignment
//    @State private var bold: Bool = defaultStyle().bold
//    @State private var italic: Bool = defaultStyle().italic
//    @State private var underline: Bool = defaultStyle().underline
    
//    func updateView() -> Void {
//        DispatchQueue.global(qos: .userInteractive).async {
//            self.font = self.style.font
//            self.size = self.style.size
//            self.color = self.style.color
//            self.position = self.style.position
//            self.alignment = self.style.alignment
//            self.bold = self.style.bold
//            self.italic = self.style.italic
//            self.underline = self.style.underline
//        }
//    }
    
//    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat, textWidth: CGFloat, textHeight: CGFloat) {
//        if position.width + textWidth >= maxWidth { position.width = maxWidth - textWidth }
//        if position.width - textWidth <= -maxWidth { position.width = -maxWidth + textWidth }
//        if position.height + textHeight >= maxHeight { position.height = maxHeight - textHeight }
//        if position.height - textHeight <= -maxHeight { position.height = -maxHeight + textHeight }
//    }
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat, textWidth: CGFloat, textHeight: CGFloat) {
        if style.position.width + textWidth >= maxWidth { style.position.width = maxWidth - textWidth }
        if style.position.width - textWidth <= -maxWidth { style.position.width = -maxWidth + textWidth }
        if style.position.height + textHeight >= maxHeight { style.position.height = maxHeight - textHeight }
        if style.position.height - textHeight <= -maxHeight { style.position.height = -maxHeight + textHeight }
    }

    // Consider caption timings when displaying caption text
    var displayText: Bool {
        guard app.mode == .play else { return true }  // always display in edit modes
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
                        if self.app.mode == .play { self.app.transition(to: .pause) }
                        else { self.app.transition(to: .play) }
                    }
                
                if self.displayText {
                        
                    Text(self.caption.text)
                    .attributes(_bold: self.style.bold, _italic: self.style.italic, _underline: self.style.underline)
                    .customFont(name: self.style.font, size: self.style.size, color: self.style.color, alignment: self.style.alignment)
                        .offset(x: self.localPos.width, y: self.localPos.height)
                    //.frame(width: 600, height: 200)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in

                                // Break down coords into 2D components
                                self.localPos.width = self.style.position.width + gesture.translation.width
                                self.localPos.height = self.style.position.height + gesture.translation.height

                                // Keep caption within video frame bounds
                                self.restrictDrag(
                                    maxWidth: geometry.size.width/2,
                                    maxHeight: geometry.size.height/2,
                                    textWidth: 0/2,
                                    textHeight: 0/2
                                )
                            }
                            .onEnded { _ in
                                // Save positional coords
                                //self.app.captions[self.index].style.position = self.position
                                self.style.position = self.localPos
                            }
                    )
                }
                
                // Style editor
                if self.app.mode != .play { TextStyler(color: self.$caption.style.color).offset(y: -290) }
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: .updateStyle)) { animate in
//            if (animate.object as! Bool == true) { withAnimation { self.updateView() } }
//            else { self.updateView() }
//            //print("animate: ", animate.object as! Bool)
//        }
    }
}

func publishToVisualOverlay(animate: Bool = false) -> Void {
    NotificationCenter.default.post(name: .updateStyle, object: animate)
}

//@available(macCatalyst 13, *)
struct CustomFont: ViewModifier {
    //@Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat
    var color: NSColor
    var alignment: TextAlignment

    func body(content: Content) -> some View {
        let modifier = content
            .font(.custom(name, size: size))
            .foregroundColor(Color(color))
            .multilineTextAlignment(alignment)
            .lineLimit(2)
        return modifier
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont (name: String, size: CGFloat, color: NSColor, alignment: TextAlignment) -> some View {
        return self.modifier(CustomFont(name: name, size: size, color: color, alignment: alignment))
    }
}

extension Text {
    func attributes (_bold: Bool, _italic: Bool, _underline: Bool) -> some View {
        
        var modifier: Text = self
        switch _bold {
        case true: modifier = modifier.bold()
        case false: ()
        }
        switch _italic {
        case true: modifier = modifier.italic()
        case false: ()
        }
        switch _underline {
        case true: modifier = modifier.underline()
        case false: ()
        }
        
        return modifier
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay(caption: .constant(Caption()))
        .environmentObject(AppState())
        .frame(height: 500)
    }
}
