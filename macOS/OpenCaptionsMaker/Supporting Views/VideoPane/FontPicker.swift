//
//  FontPicker.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 12/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine

struct FontPicker: View {

    @State var selectedFont: String
    //@EnvironmentObject var app: AppState
    
    let fontFamilyNames = NSFontManager.shared.availableFontFamilies
    
    var body: some View {
        
        Picker("Select a font", selection: $selectedFont) {
            ForEach(fontFamilyNames, id: \.self) {
                Text($0).font(.custom($0, size: 15))
            }
        }
        .labelsHidden()
        .id(selectedFont)
        .animation(.spring())
        
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker(selectedFont: "Arial")
    }
}
