//
//  Styler.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//
import SwiftUI

struct Styler: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var app: AppState
    @Binding var style: Style
    @State var isPickingColor: Bool = false
    
    let barThickness: CGFloat
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
    var body: some View {
                
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(colorScheme == .dark ? Color.black : Color.white)
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
                
                // ColorPicker UX isn't ideal but it works for now
                Button() { isPickingColor.toggle() }
                    label: { Image(systemName: "paintpalette.fill") }
                if isPickingColor {
                    ColorPicker("", selection: $style.color, supportsOpacity: true)
                        .frame(width: barThickness, height: barThickness*0.8)
                }
            }
            .frame(height: barThickness)
            .buttonStyle(buttonStyle)
            .font(.system(size: 20))
            .onReceive(app.$selectedIndex) { _ in isPickingColor = false }
        }
        .animation(.spring())
    }
}

struct Styler_Previews: PreviewProvider {
    
    static var previews: some View {
        Styler(style: .constant(defaultStyle()), barThickness: 35)
            .frame(width: 1000, height: 300)
    }
}
