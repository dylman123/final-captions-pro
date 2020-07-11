//
//  TextView.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct TextView: View {
    
    // Constants
    let textWidth = CGFloat(250.0)
    let textOffset = CGFloat(-40.0)
    let deltaOffset = CGFloat(6.0)
    
    // Variables
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowProperties
    
    // The current caption binding (for text)
    var binding: Binding<Caption> {
        return $app.captions[row.index]
    }
    
    // Horizontal adjustment
    var horizontalAdjuster: CGFloat {
        if !row.isSelected { return textOffset }
        switch app.mode {
        case .play: return textOffset
        case .pause: return textOffset + 6
        case .edit: return textOffset - 5
        case .editStartTime: return textOffset - 5
        case .editEndTime: return textOffset - 5
        }
    }
    
    var body: some View {
        
        Group<AnyView> {
            if row.isSelected {
                // Caption text
                return AnyView(ZStack {
                    if app.mode == .edit {
                        TextField(row.caption.text, text: binding.text, onCommit: {
                            guard binding.text.wrappedValue != "" else { return }
                            DispatchQueue.main.async {
                                NSApp.keyWindow?.makeFirstResponder(nil)
                            }
                            NotificationCenter.default.post(name: .handoverNSResponder, object: nil)
//                            NotificationCenter.default.post(name: .returnKey, object: nil)
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onExitCommand {
                            print("ESC from TextField")
                        }
                    } else {
                        Text(row.caption.text)
                    }
                })
            
            }
            else { return AnyView(Text(row.caption.text)) }
        }
        .offset(x: horizontalAdjuster)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .clickable(app, row, fromView: .text)
        .frame(width: textWidth)
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
            .environmentObject(RowProperties(Caption(), 0, true, 1, .black))
    }
}
