//
//  Tag.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 2/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Tag: View {
    
    var state: AppState
    var caption: Caption
    var isSelected: Bool
    
    init(_ rowState: RowState) {
        self.state = rowState.appState
        self.caption = rowState.caption
        self.isSelected = rowState.isSelected
    }
    
    var body: some View {
        if caption.tag != "" || (isSelected && state.mode != .play) {
            return AnyView(TagView(caption.tag).offset(x: 180))
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct TagView: View {
    
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
        TagView("g")
    }
}
