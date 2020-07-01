//
//  Tag.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct Tag: View {
    
    // Variables
    @EnvironmentObject var app: AppState
    var row: RowState
    init(_ row: RowState) {
        self.row = row
    }
    
    var body: some View {
        if row.caption.style.symbol != nil || (row.isSelected && app.mode != .play) {
            //print("Symbol: ", self.row.caption.style.symbol as Any)
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
            Image(systemName: "NSTouchBarTagIconTemplate")
            //IconView("NSTouchBarTagIconTemplate")
            Text(symbol)
        }
        .frame(width: 30, height: 20)
        
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        TagView("g")
        .environmentObject(AppState())
    }
}
