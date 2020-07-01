//
//  FontPicker.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI
import Combine

struct FontPicker: View {

    @Binding var font: String
    
    let fontFamilyNames = NSFontManager.shared.availableFontFamilies
    
    var body: some View {
        
        Picker("Select a font", selection: $font) {
            ForEach(fontFamilyNames, id: \.self) {
                Text($0).font(.custom($0, size: 15))
            }
        }
        .labelsHidden()
        .id(font)
        
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker(font: .constant("Arial"))
    }
}
