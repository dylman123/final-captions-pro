//
//  TextStyler.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 10/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct TextStyler: View {
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
                
                IconView("NSTouchBarTextLeftAlignTemplate")
                IconView("NSTouchBarTextCenterAlignTemplate")
                IconView("NSTouchBarTextRightAlignTemplate")

                IconView("NSTouchBarGoDownTemplate")
                IconView("NSTouchBarGoUpTemplate")
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
