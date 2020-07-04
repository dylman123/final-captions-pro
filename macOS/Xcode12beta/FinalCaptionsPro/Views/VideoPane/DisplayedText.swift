//
//  DisplayedText.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct DisplayedText: View {
    
    @Binding var text: String
    @Binding var font: String
    @Binding var size: CGFloat
    @Binding var color: Color
    @Binding var position: CGSize
    @Binding var alignment: TextAlignment
    @Binding var bold: Bool
    @Binding var italic: Bool
    @Binding var underline: Bool
    var geometry: GeometryProxy
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat, textWidth: CGFloat, textHeight: CGFloat) {
        if position.width + textWidth >= maxWidth { position.width = maxWidth - textWidth }
        if position.width - textWidth <= -maxWidth { position.width = -maxWidth + textWidth }
        if position.height + textHeight >= maxHeight { position.height = maxHeight - textHeight }
        if position.height - textHeight <= -maxHeight { position.height = -maxHeight + textHeight }
    }
    
    var body: some View {
        Text(text)
            .attributes(_bold: bold, _italic: italic, _underline: underline)
            .customFont(name: font, size: size, color: color, alignment: alignment)
            .offset(x: position.width, y: position.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in

                        // Break down coords into 2D components
                        position.width = gesture.location.x
                        position.height = gesture.location.y

                        // Keep caption within video frame bounds
                        restrictDrag(
                            maxWidth: geometry.size.width/2,
                            maxHeight: geometry.size.height/2,
                            textWidth: 0/2,
                            textHeight: 0/2
                        )
                    }
            )
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

//struct DisplayedText_Previews: PreviewProvider {
//    static var previews: some View {
//        DisplayedText(text: .constant("test"), position: .constant(CGSize(width: 10, height: 10))
//    }
//}
