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
//    private var font: String { style.font }
//    private var size: CGFloat { style.size }
//    private var color: Color { style.color }
//    private var alignment: TextAlignment { style.alignment }

    @State private var font: String = defaultStyle().font
    @State private var size: CGFloat = defaultStyle().size
    @State private var color: NSColor = defaultStyle().color
    @State private var position: CGSize = defaultStyle().position
    @State private var alignment: TextAlignment = defaultStyle().alignment
    
    func updateView() -> Void {
        font = style.font
        size = style.size
        color = style.color
        position = style.position
        alignment = style.alignment
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
                //.underline().italic().bold().strikethrough()
                .customFont(name: font, size: size, color: color, alignment: alignment)
                .offset(x: position.width, y: position.height)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Break down coords into 2D components
                            self.position.width = self.style.position.width + gesture.translation.width
                            self.position.height = self.style.position.height + gesture.translation.height
                            
                            // Keep caption within video frame bounds
                            self.restrictDrag(maxWidth: 400, maxHeight: 300)
                        }
                        .onEnded { _ in
                            // Save positional coords
                            self.app.captions[self.index].style.position = self.position
                        }
                )
            
            // Style editor
            TextStyler(color: $color).offset(y: -290)
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
        //let scaledSize = UIFontMetrics.default.scaledValue(for: size)
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
    func customFont (
        name: String,
        size: CGFloat,
        color: NSColor,
        alignment: TextAlignment
    ) -> some View {
        
        return self.modifier(
            CustomFont (
            name: name,
            size: size,
            color: color,
            alignment: alignment
        ))
    }
}

//extension View {
//    func customAttributes (bold: Bool, italic: Bool, underline: Bool, strikethrough: Bool) -> some View {
//        //return .bold()
//    }
//}

struct VisualOverlay_Previews: PreviewProvider {
    static var previews: some View {
        VisualOverlay()
        .environmentObject(AppState())
        .frame(height: 500)
    }
}
