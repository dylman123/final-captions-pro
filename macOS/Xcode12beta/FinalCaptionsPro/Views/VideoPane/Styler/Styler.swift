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
    
    var body: some View {
                
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.8))
                .frame(height: barThickness)
            
            HStack(spacing: 15) {
                
                BoldItalicUnderline (
                    bold: $style.bold,
                    italic: $style.italic,
                    underline: $style.underline
                )
                
                Alignment(alignment: $style.alignment)
                
                Sizer(size: $style.size)
                
                FontPicker(font: $style.font)
                    .frame(width: 200)
                
                ColorPicker("", selection: $style.color, supportsOpacity: true)
                    .frame(width: barThickness, height: barThickness*0.8)
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
