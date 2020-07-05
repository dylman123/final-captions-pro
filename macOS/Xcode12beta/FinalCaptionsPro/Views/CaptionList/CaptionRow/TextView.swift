//
//  TextView.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct TextView: View {
    
    // Constants
    let textWidth = CGFloat(300.0)
    let textOffset = CGFloat(-40.0)
    let deltaOffset = CGFloat(6.0)
    
    // Variables
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowProperties
    
    // The current caption binding (for text)
    var binding: Binding<Caption> {
        return $app.captions[row.index]
    }
    
    var body: some View {
        
        if row.isSelected {
            // Caption text
            return AnyView(ZStack {
                if app.mode == .edit {
                    TextField(row.caption.text, text: binding.text, onCommit: {
                        guard binding.text.wrappedValue != "" else { return }
                        NotificationCenter.default.post(name: .returnKey, object: nil)
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(row.caption.text)
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .clickable(app, row, fromView: .text)
            .offset(x: textOffset + deltaOffset)
            .frame(width: textWidth)
            )
        
        }
        else {
            return AnyView(Text(row.caption.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: textWidth)
                .offset(x: textOffset)
                .clickable(app, row, fromView: .text)
            )
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
            .environmentObject(RowProperties(Caption(), 0, true, 1, .black))
    }
}
