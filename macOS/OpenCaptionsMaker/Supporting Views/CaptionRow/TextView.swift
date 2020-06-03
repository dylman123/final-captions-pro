//
//  TextView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 3/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct TextView: View {
    
    // Constants
    let textWidth = CGFloat(300.0)
    let textOffset = CGFloat(-40.0)
    let deltaOffset = CGFloat(6.0)
    
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
        
        if isSelected {
            // Caption text
            return AnyView(ZStack {
                if appState.mode == .play {
                    Text(caption.text).offset(x: -5)
                } else if appState.mode == .edit {
                    Text(caption.text + "|").offset(x: 2)  // TODO: Make cursor blink
                    SelectionBox()
                } else { Text(caption.text) }
            }
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .clickable(row, fromView: .text)
            .offset(x: textOffset + deltaOffset)
            .frame(width: textWidth))
        
        }
        else {
            return AnyView(Text(caption.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: textWidth)
                .offset(x: textOffset)
                .clickable(row, fromView: .text))
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(RowState(AppState(), Caption()))
            .environmentObject(AppState())
    }
}
