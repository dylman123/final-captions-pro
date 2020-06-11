//
//  TextStyler.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 10/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import ColorPicker
import DynamicColor

struct TextStyler: View {
    
    @EnvironmentObject var app: AppState
    
    @State private var color = NSColor.red
    @State private var isEditingColor = false
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
    func updateAlignment(to alignment: TextAlignment) -> Void {
        app.captions[app.selectedIndex].style.alignment = alignment
        publishToVisualOverlay(animate: true)
    }
    func updateSize(by step: CGFloat) -> Void {
        app.captions[app.selectedIndex].style.size += step
        publishToVisualOverlay(animate: false)
    }
    
    var body: some View {
                
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.8))
                .frame(height: 35)
            
            HStack(spacing: 15) {
                
                // Bold, Italic, Underline
                Group {
                    Button(action: {}, label: {IconView("NSTouchBarTextBoldTemplate")})
                    Button(action: {}, label: {IconView("NSTouchBarTextItalicTemplate")})
                    Button(action: {}, label: {IconView("NSTouchBarTextUnderlineTemplate")})
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
                    Button(action: { self.updateSize(by: -10) },
                           label: {IconView("NSTouchBarGoDownTemplate")})
                    
                    Button(action: { self.updateSize(by: 10) },
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
        TextStyler()
            .frame(width: 1000, height: 300)
    }
}
