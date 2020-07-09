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
    @EnvironmentObject var row: RowProperties
    
    var body: some View {
        if row.caption.style.symbol != nil || (row.isSelected && app.mode != .play) {
            return AnyView(
                TagView(row.caption.style.symbol ?? "")
                    .offset(x: 200)
                    .clickable(app, row, fromView: .row)
                    .font(.system(size: 20))
                    .foregroundColor(row.caption.style.color)
                    .brightness(0.3)
                )
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct TagView: View {
    
    private var symbol: String
    private var lowercase: String
    
    init(_ symbol: String = "") {
        self.symbol = symbol
        self.lowercase = symbol.lowercased()
    }
    
    var body: some View {
        
        Group {
            if symbol != "" {
                Image(systemName: "\(lowercase).circle.fill")

            }
            else {
                Image(systemName: "circle.fill")
            }
        }
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        TagView("g")
    }
}
