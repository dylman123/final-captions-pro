//
//  PlusMinus.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct PlusMinus: View {
    
    // To format the buttons
    var buttonStyle = BorderlessButtonStyle()
    
    // Variables
    @EnvironmentObject var app: AppState
    var row: RowState
    init(_ row: RowState) {
        self.row = row
    }
    
    var body: some View {
        
        VStack {
            // Plus button
            Button(action: {
                self.app.captions = addCaption(toArray: self.app.captions, beforeIndex: self.row.index, atTime: self.row.caption.start)
            }) { if app.mode != .play {  // Don't show +- buttons in play mode
                Image(systemName: "NSAddTemplate")
                //IconView("NSAddTemplate")
                    .frame(width: 12, height: 12)
                }
            }
            
            // Minus button
            Button(action: {
                self.app.captions = deleteCaption(fromArray: self.app.captions, atIndex: self.row.index)
            }) {
                if (app.mode != .play) && (app.captions.count > 1) {  // Don't give option to delete when only 1 caption is in list
                    Image(systemName: "NSRemoveTemplate")
                    //IconView("NSRemoveTemplate")
                    .frame(width: 12, height: 12)
                }
            }
        }
        .buttonStyle(buttonStyle)
        
    }
}

struct PlusMinus_Previews: PreviewProvider {
    static var previews: some View {
        PlusMinus(RowState())
        .environmentObject(AppState())
    }
}
