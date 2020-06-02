//
//  Tag.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 2/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Tag: View {
    
    @State var symbol: String
    
    var body: some View {
        
        ZStack {
            IconView("NSTouchBarTagIconTemplate")
            Text(symbol)
        }
        
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag(symbol: "A")
    }
}
