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
            RoundedRectangle(cornerRadius: 5)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.white, lineWidth: 3)
            )
            
            HStack {
                IconView("NSTouchBarTextBoldTemplate")
                IconView("NSTouchBarTextItalicTemplate")
                IconView("NSTouchBarTextUnderlineTemplate")
                
                Button(action: {
                    self.updateAlignment(to: .leading)
                }, label: {IconView("NSTouchBarTextLeftAlignTemplate")})
                
                Button(action: {
                    self.updateAlignment(to: .center)
                }, label: {IconView("NSTouchBarTextCenterAlignTemplate")})
                
                Button(action: {
                    self.updateAlignment(to: .trailing)
                }, label: {IconView("NSTouchBarTextRightAlignTemplate")})
                
                Button(action: {
                    self.updateSize(by: -10)
                }, label: {IconView("NSTouchBarGoDownTemplate")})
                
                Button(action: {
                    self.updateSize(by: 10)
                }, label: {IconView("NSTouchBarGoUpTemplate")})
                
                IconView("NSFontPanel")
                ColorWellView()
            }
            
        }
        .frame(width: 400, height: 35)
    }
}

struct TextStyler_Previews: PreviewProvider {
    static var previews: some View {
        TextStyler()
    }
}
