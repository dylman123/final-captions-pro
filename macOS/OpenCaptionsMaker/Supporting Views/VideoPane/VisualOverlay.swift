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
    private var index: Int { app.selectedIndex }
    private var caption: Caption { app.captions[index] }
    private var style: Style { caption.style }
    private var videoFrame: CGRect { app.videoFrame }

    @State private var font: String = defaultStyle().font
    @State private var size: CGFloat = defaultStyle().size
    @State private var color: NSColor = defaultStyle().color
    @State private var position: CGSize = defaultStyle().position
    @State private var alignment: TextAlignment = defaultStyle().alignment
    @State private var bold: Bool = defaultStyle().bold
    @State private var italic: Bool = defaultStyle().italic
    @State private var underline: Bool = defaultStyle().underline
    @State private var strikethrough: Bool = defaultStyle().strikethrough
    
    func updateView() -> Void {
        DispatchQueue.global(qos: .userInteractive).async {
            self.font = self.style.font
            self.size = self.style.size
            self.color = self.style.color
            self.position = self.style.position
            self.alignment = self.style.alignment
            self.bold = self.style.bold
            self.italic = self.style.italic
            self.underline = self.style.underline
            self.strikethrough = self.style.strikethrough
        }
    }
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat) {
        if position.width >= maxWidth { position.width = maxWidth }
        if position.width <= -maxWidth { position.width = -maxWidth }
        if position.height >= maxHeight { position.height = maxHeight }
        if position.height <= -maxHeight { position.height = -maxHeight }
    }
    
    var body: some View {
            
        ZStack {
            // Color.clear is undetected by onTapGesture
            Rectangle().fill(Color.blue.opacity(0.001))
                .onTapGesture {
                    if self.app.mode == .play { self.app.transition(to: .pause) }
                    else { self.app.transition(to: .play) }
                }
            
            Text(caption.text)
                .attributes(_bold: bold, _italic: italic, _underline: underline, _strikethrough: strikethrough)
                .customFont(name: font, size: size, color: color, alignment: alignment)
                .offset(x: position.width, y: position.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Break down coords into 2D components
                            self.position.width = self.style.position.width + gesture.translation.width
                            self.position.height = self.style.position.height + gesture.translation.height
                            
                            // Keep caption within video frame bounds
                            self.restrictDrag(maxWidth: self.videoFrame.width/2, maxHeight: self.videoFrame.height/2)
                        }
                        .onEnded { _ in
                            // Save positional coords
                            self.app.captions[self.index].style.position = self.position
                        }
                )
            
            // Style editor
            if app.mode != .play { TextStyler(color: $color).offset(y: -290) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateStyle)) { animate in
            if (animate.object as! Bool == true) { withAnimation { self.updateView() } }
            else { self.updateView() }
        }
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
    func attributes (_bold: Bool, _italic: Bool, _underline: Bool, _strikethrough: Bool) -> some View {
        
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
        switch _strikethrough {
        case true: modifier = modifier.strikethrough()
        case false: ()
        }
        
        return modifier
    }
}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay()
        .environmentObject(AppState())
        .frame(height: 500)
    }
}
