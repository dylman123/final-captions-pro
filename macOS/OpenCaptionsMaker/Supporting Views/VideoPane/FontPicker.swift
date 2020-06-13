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
    //@EnvironmentObject var app: AppState
    @State var selectedFont: Set<String>
    let fontFamilyNames = NSFontManager.shared.availableFontFamilies
    
    var body: some View {
        
        List(selection: $selectedFont) {
            ForEach(fontFamilyNames, id: \.self) {
                Text($0).font(.custom($0, size: 15))
            }
        }
        
    }
    
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker(selectedFont: .init(minimumCapacity: 0))
    }
}
