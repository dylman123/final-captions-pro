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
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowState
    
    var body: some View {
        
        VStack {
            // Plus button
            Button(action: {
                self.app.userData = addCaption(toArray: self.app.userData, beforeIndex: self.row.index, atTime: self.row.data.caption.startTime)
            }) { if app.mode != .play {  // Don't show +- buttons in play mode
                IconView("NSAddTemplate")
                    .frame(width: 12, height: 12)
                }
            }
            
            // Minus button
            Button(action: {
                self.app.userData = deleteCaption(fromArray: self.app.userData, atIndex: self.row.index)
            }) {
                if (app.mode != .play) && (app.userData.count > 1) {  // Don't give option to delete when only 1 caption is in list
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
        PlusMinus()
        .environmentObject(AppState())
        .environmentObject(RowState())
    }
}
