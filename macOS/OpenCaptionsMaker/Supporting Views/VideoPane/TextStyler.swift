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
        
        HStack {
            IconView("")
            ColorWellView()
        }
        .frame(width: 200, height: 50)
    }
}

struct TextStyler_Previews: PreviewProvider {
    static var previews: some View {
        TextStyler()
    }
}
