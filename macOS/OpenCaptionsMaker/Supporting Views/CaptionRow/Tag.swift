//
//  Tag.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 2/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Tag: View {
    
    // Variables
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowState
    
    var body: some View {
        if row.caption.style.symbol != nil || (row.isSelected && app.mode != .play) {
            return AnyView(
                TagView(row.caption.style.symbol ?? "")
                    .offset(x: 180)
                    .clickable(row, fromView: .row)
                )
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct TagView: View {
    
    private var symbol: String
    
    init(_ symbol: String = "") {
        self.symbol = symbol
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
        .environmentObject(AppState())
        .environmentObject(RowState())
    }
}
