//
//  PlusMinus.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 3/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct PlusMinus: View {
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
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
        
        VStack {
            // Plus button
            Button(action: {
                self.appState.captions = addCaption(toArray: self.appState.captions, beforeIndex: self.index, atTime: self.caption.startTime)
            }) { if appState.mode != .play {  // Don't show +- buttons in play mode
                IconView("NSAddTemplate")
                    .frame(width: 12, height: 12)
                }
            }
            
            // Minus button
            Button(action: {
                self.appState.captions = deleteCaption(fromArray: self.appState.captions, atIndex: self.index)
            }) {
                if (appState.mode != .play) && (appState.captions.count > 1) {  // Don't give option to delete when only 1 caption is in list
                    IconView("NSRemoveTemplate")
                    .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(buttonStyle)
        
    }
}

struct PlusMinus_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinus(RowState(AppState(), Caption()))
    }
}
