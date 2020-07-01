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
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat, textWidth: CGFloat, textHeight: CGFloat) {
        if caption.style.position.width + textWidth >= maxWidth { caption.style.position.width = maxWidth - textWidth }
        if caption.style.position.width - textWidth <= -maxWidth { caption.style.position.width = -maxWidth + textWidth }
        if caption.style.position.height + textHeight >= maxHeight { caption.style.position.height = maxHeight - textHeight }
        if caption.style.position.height - textHeight <= -maxHeight { caption.style.position.height = -maxHeight + textHeight }
    }

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
                        if self.app.mode == .play { self.app.transition(to: .pause) }
                        else { self.app.transition(to: .play) }
                    }
                
                if self.displayText {
                        
                    Text(self.caption.text)
                        .attributes(_bold: self.caption.style.bold, _italic: self.caption.style.italic, _underline: self.caption.style.underline)
                        .customFont(name: self.caption.style.font, size: self.caption.style.size, color: self.caption.style.color, alignment: self.caption.style.alignment)
                        .offset(x: self.caption.style.position.width, y: self.caption.style.position.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in

                                    // Break down coords into 2D components
                                    self.caption.style.position.width = gesture.location.x
                                    self.caption.style.position.height = gesture.location.y

                                    // Keep caption within video frame bounds
                                    self.restrictDrag(
                                        maxWidth: geometry.size.width/2,
                                        maxHeight: geometry.size.height/2,
                                        textWidth: 0/2,
                                        textHeight: 0/2
                                    )
                                }
                        )
                }
                
                // Style editor
                if self.app.mode != .play { Styler(style: self.$caption.style).offset(y: -290) }
            }
        }
    }
}

//@available(macCatalyst 13, *)
struct CustomFont: ViewModifier {
    //@Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat
    var color: Color
    var alignment: TextAlignment

    func body(content: Content) -> some View {
        let modifier = content
            .font(.custom(name, size: size))
            .foregroundColor(color)
            .multilineTextAlignment(alignment)
            .lineLimit(2)
        return modifier
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont (name: String, size: CGFloat, color: Color, alignment: TextAlignment) -> some View {
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
