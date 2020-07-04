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
    @EnvironmentObject var row: RowProperties
    
    var body: some View {
        
        VStack {
            // Plus button
            Button(action: {
                app.captions = addCaption(toArray: app.captions, beforeIndex: row.index, atTime: row.caption.start)
            }) { if app.mode != .play {  // Don't show +- buttons in play mode
                Image(systemName: "plus")
                //IconView("NSAddTemplate")
                    .frame(width: 12, height: 12)
                }
            }
            
            // Minus button
            Button(action: {
                app.captions = deleteCaption(fromArray: app.captions, atIndex: row.index)
            }) {
                if (app.mode != .play) && (app.captions.count > 1) {  // Don't give option to delete when only 1 caption is in list
                    Image(systemName: "minus")
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
        PlusMinus()
            .environmentObject(RowProperties(Caption(), 0, true, 1, .black))
    }
}
