//
//  TextStyler.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 10/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct TextStyler: View {
    
    @EnvironmentObject var app: AppState
    @Binding var color: NSColor
    @State private var isEditingColor = false
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
    enum TextAttribute { case bold, italic, underline, strikethrough }
    func updateTextAttribute(_ attribute: TextAttribute) -> Void {
        switch attribute {
        case .bold: app.captions[app.selectedIndex].style.bold.toggle()
        case .italic: app.captions[app.selectedIndex].style.italic.toggle()
        case .underline: app.captions[app.selectedIndex].style.underline.toggle()
        case .strikethrough: app.captions[app.selectedIndex].style.strikethrough.toggle()
        }
        publishToVisualOverlay(animate: false)
    }
    
    func updateAlignment(to alignment: TextAlignment) -> Void {
        app.captions[app.selectedIndex].style.alignment = alignment
        publishToVisualOverlay(animate: true)
    }
    func updateSize(by step: CGFloat) -> Void {
        app.captions[app.selectedIndex].style.size += step
        let newSize = app.captions[app.selectedIndex].style.size
        if newSize < 10 { app.captions[app.selectedIndex].style.size = 10 }
        if newSize > 200 { app.captions[app.selectedIndex].style.size = 200 }
        publishToVisualOverlay(animate: false)
    }
    
    var body: some View {
                
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.8))
                .frame(height: 35)
            
            HStack(spacing: 15) {
                
                // Bold, Italic, Underline, Strikethrough
                Group {
                    Button(action: {self.updateTextAttribute(.bold)},
                           label: {IconView("NSTouchBarTextBoldTemplate")})
                    
                    Button(action: {self.updateTextAttribute(.italic)},
                           label: {IconView("NSTouchBarTextItalicTemplate")})
                    
                    Button(action: {self.updateTextAttribute(.underline)},
                           label: {IconView("NSTouchBarTextUnderlineTemplate")})
                    
                    Button(action: {self.updateTextAttribute(.strikethrough)},
                           label: {IconView("NSTouchBarTextStrikethroughTemplate")})
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
                    
                    Button(action: {}, label: {IconView("NSFontPanel")})
                    
                    Button(action: { self.isEditingColor.toggle() },
                           label: {IconView("NSTouchBarColorPickerStroke")})
                }
            }
            .frame(height: 35)
            .buttonStyle(buttonStyle)
            
            if isEditingColor && app.mode != .play {
                ColorPicker(color: $color, strokeWidth: 20)
                .frame(width: 100, height: 100, alignment: .center)
                .offset(x: 420, y: 80)
            }
        }
    }
}

struct TextStyler_Previews: PreviewProvider {
    
    static var previews: some View {
        TextStyler(color: .constant(.red))
            .frame(width: 1000, height: 300)
    }
}
