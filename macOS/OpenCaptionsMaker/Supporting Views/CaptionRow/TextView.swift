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
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowState
    
    var body: some View {
        
        if row.isSelected {
            // Caption text
            return AnyView(ZStack {
                if app.mode == .play {
                    Text(row.data.caption.text).offset(x: -5)
                } else if app.mode == .edit {
                    Text(row.data.caption.text + "|").offset(x: 2)  // TODO: Make cursor blink
                    SelectionBox()
                } else { Text(row.data.caption.text) }
            }
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .clickable(row, fromView: .text)
            .offset(x: textOffset + deltaOffset)
            .frame(width: textWidth))
        
        }
        else {
            return AnyView(Text(row.data.caption.text)
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
        TextView()
        .environmentObject(AppState())
        .environmentObject(RowState())
    }
}
