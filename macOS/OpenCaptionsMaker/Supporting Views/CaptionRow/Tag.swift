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
    @EnvironmentObject var appState: AppState
    private var row: RowState  // An object to hold the state of the current row
    private var caption: Caption  // The caption object in the current row
    private var isSelected: Bool  // Is the current row selected?
    private var index: Int  // The current row's index in the list
    private var clickNumber: Int  // An integer to define clicking behaviour
    private var color: Color  // The current row's colour
    
    init(_ row: RowState) {
        self.row = row
        self.caption = row.caption
        self.isSelected = row.isSelected
        self.index = row.index
        self.clickNumber = row.clickNumber
        self.color = row.color
    }
    
    var body: some View {
        if caption.tag != "" || (isSelected && appState.mode != .play) {
            return AnyView(
                TagView(caption.tag)
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
            .environmentObject(AppState())
    }
}
