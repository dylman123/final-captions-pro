//
//  Styler.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct Styler: View {
    
    @Binding var style: Style
    let barThickness: CGFloat = 35
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
    enum TextAttribute { case bold, italic, underline }
    func updateTextAttribute(_ attribute: TextAttribute) -> Void {
        switch attribute {
        case .bold: style.bold.toggle()
        case .italic: style.italic.toggle()
        case .underline: style.underline.toggle()
        }
    }
    
    func updateAlignment(to alignment: TextAlignment) -> Void {
        style.alignment = alignment
    }
    func updateSize(by step: CGFloat) -> Void {
        style.size += step
        let newSize = style.size
        if newSize < 10 { style.size = 10 }
        if newSize > 200 { style.size = 200 }
    }
    
    var body: some View {
                
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.8))
                .frame(height: barThickness)
            
            HStack(spacing: 15) {
                
                // Bold, Italic, Underline
                Group {
                    Button(action: {self.updateTextAttribute(.bold)},
                           label: {Image(systemName: "bold")})
                    
                    Button(action: {self.updateTextAttribute(.italic)},
                           label: {Image(systemName: "italic")})
                    
                    Button(action: {self.updateTextAttribute(.underline)},
                           label: {Image(systemName: "underline")})
                }
                // Alignment
                Group {
                    Button(action: { self.updateAlignment(to: .leading) },
                           label: {Image(systemName: "text.justifyleft")})
                    
                    Button(action: { self.updateAlignment(to: .center) },
                           label: {Image(systemName: "text.justify")})
                    
                    Button(action: { self.updateAlignment(to: .trailing) },
                           label: {Image(systemName: "text.justifyright")})
                }
                // Size, Font, Color
                Group {
                    Button(action: { self.updateSize(by: -5) },
                           label: {Image(systemName: "chevron.down")})
                    
                    Button(action: { self.updateSize(by: 5) },
                           label: {Image(systemName: "chevron.up")})
                    
                    FontPicker(font: $style.font)
                        .frame(width: 200)
                    
                    ColorPicker("", selection: $style.color, supportsOpacity: true)
                        .frame(width: barThickness*0.8, height: barThickness*0.8)
                }
            }
            .frame(height: barThickness)
            .buttonStyle(buttonStyle)
            
        }
        .animation(.spring())
    }
}

struct Styler_Previews: PreviewProvider {
    
    static var previews: some View {
        Styler(style: .constant(defaultStyle()))
            .frame(width: 1000, height: 300)
    }
}
