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
                           label: {IconView("NSTouchBarTextBoldTemplate")})
                    
                    Button(action: {self.updateTextAttribute(.italic)},
                           label: {IconView("NSTouchBarTextItalicTemplate")})
                    
                    Button(action: {self.updateTextAttribute(.underline)},
                           label: {IconView("NSTouchBarTextUnderlineTemplate")})
                }
                // Alignment
                Group {
                    Button(action: { self.updateAlignment(to: .leading) },
                           label: {IconView("NSTouchBarTextLeftAlignTemplate")})
                    
                    Button(action: { self.updateAlignment(to: .center) },
                           label: {IconView("NSTouchBarTextCenterAlignTemplate")})
                    
                    Button(action: { self.updateAlignment(to: .trailing) },
                           label: {IconView("NSTouchBarTextRightAlignTemplate")})
                }
                // Size, Font, Color
                Group {
                    Button(action: { self.updateSize(by: -5) },
                           label: {IconView("NSTouchBarGoDownTemplate")})
                    
                    Button(action: { self.updateSize(by: 5) },
                           label: {IconView("NSTouchBarGoUpTemplate")})
                    
                    FontPicker(font: $style.font)
                        .frame(width: 200)
                    
                    if #available(OSX 11.0, *) {
                        ColorPicker("", selection: $style.color, supportsOpacity: true)
                            .frame(width: barThickness*0.8, height: barThickness*0.8)
                    } else {
                        // Fallback on earlier versions
                    }
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
