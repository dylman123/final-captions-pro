//
//  Tag.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 2/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Tag: View {
    
    private var symbol: String
    
    init(_ symbol: String = "") {
        self.symbol = symbol.uppercased()
    }
    
    var body: some View {
        
        ZStack {
            IconView("NSTouchBarTagIconTemplate")
            Text(symbol)
        }
        .frame(width: 30, height: 20)
        
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        Tag("g")
    }
}
