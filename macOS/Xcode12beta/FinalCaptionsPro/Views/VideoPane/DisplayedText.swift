//
//  DisplayedText.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct DisplayedText: View {
    
    @EnvironmentObject var app: AppState
    var text: String
    var font: String
    var size: CGFloat
    var color: Color
    @Binding var position: CGSize
    var alignment: TextAlignment
    var bold: Bool
    var italic: Bool
    var underline: Bool
    var videoGeometry: GeometryProxy
    
    @State private var localPos: CGSize = defaultStyle().position
    @State private var textFrame: CGSize = .zero
    
    init (
        text: String,
        font: String,
        size: CGFloat,
        color: Color,
        position: Binding<CGSize>,
        alignment: TextAlignment,
        bold: Bool,
        italic: Bool,
        underline: Bool,
        geometry: GeometryProxy
    ) {
        self.text = text
        self.font = font
        self.size = size
        self.color = color
        self._position = position
        self.alignment = alignment
        self.bold = bold
        self.italic = italic
        self.underline = underline
        self.videoGeometry = geometry
        self.localPos = position.wrappedValue
    }
    
    func restrictDrag(maxWidth: CGFloat, maxHeight: CGFloat, textWidth: CGFloat, textHeight: CGFloat) {
        if localPos.width + textWidth >= maxWidth { localPos.width = maxWidth - textWidth }
        if localPos.width - textWidth <= -maxWidth { localPos.width = -maxWidth + textWidth }
        if localPos.height + textHeight >= maxHeight { localPos.height = maxHeight - textHeight }
        if localPos.height - textHeight <= -maxHeight { localPos.height = -maxHeight + textHeight }
    }
    
    var body: some View {

        Text(text)
            .attributes(_bold: bold, _italic: italic, _underline: underline)
            .customFont(name: font, size: size, color: color, alignment: alignment)
            .offset(x: localPos.width, y: localPos.height)
            .overlay(
                GeometryReader { proxy in
                    Text("")  // Just needs to be some View that isn't an EmptyView()
                        .onReceive(app.captions[app.selectedIndex].style.$size) { _ in textFrame = proxy.size }
                }
            )
            .gesture(
                DragGesture()
                    .onChanged { gesture in

                        let absoluteWidth = position.width * app.exporter.videoFileDimensions.width
                        let absoluteHeight = position.height * app.exporter.videoFileDimensions.height
                        
                        // Break down coords into 2D components
                        localPos.width = absoluteWidth + gesture.translation.width
                        localPos.height = absoluteHeight + gesture.translation.height

                        // Keep caption within video frame bounds
                        restrictDrag(
                            maxWidth: videoGeometry.size.width/2,
                            maxHeight: videoGeometry.size.height/2,
                            textWidth: textFrame.width/2,
                            textHeight: textFrame.height/2
                        )
                    }
                    .onEnded { _ in
                        position.width = localPos.width / app.exporter.videoFileDimensions.width
                        position.height = localPos.height / app.exporter.videoFileDimensions.height
                    }
            )

        // Need to listen to caption position to update localPos
        .onChange(of: app.captions[app.selectedIndex].style.position) { _ in
            localPos.width = position.width * app.exporter.videoFileDimensions.width
            localPos.height = position.height * app.exporter.videoFileDimensions.height
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateStyle)) { _ in
            withAnimation {
                localPos.width = position.width * app.exporter.videoFileDimensions.width
                localPos.height = position.height * app.exporter.videoFileDimensions.height
            }
        }
        .onChange(of: app.exporter.videoFileDimensions) { dimensions in
            localPos.width = position.width * dimensions.width
            localPos.height = position.height * dimensions.height
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

//@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func customFont (name: String, size: CGFloat, color: Color, alignment: TextAlignment) -> some View {
        return self.modifier(CustomFont(name: name, size: size, color: color, alignment: alignment))
    }
}

extension Text {
    func attributes(_bold: Bool, _italic: Bool, _underline: Bool) -> some View {

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
