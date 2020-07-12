//
//  RepeatButton.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 8/7/20.
//

import SwiftUI

struct RepeatButton: View {
    
    @EnvironmentObject var app: AppState
    @EnvironmentObject var row: RowProperties
    private var isDisplayed: Bool {
        switch app.mode {
        case .play, .pause: return false
        case .edit, .editStartTime, .editEndTime: return true
        }
    }
    
    var body: some View {
        
        Group<AnyView> {
            
            if isDisplayed {
                return AnyView (
                    Button {
                        // Mimic a transition back to edit mode to trigger a repeat
                        NotificationCenter.default.post(name: .edit, object: nil)
                    } label: {
                        Image(systemName: "repeat")
                    }.buttonStyle(BorderlessButtonStyle())
                )
            } else {
                return AnyView (
                    EmptyView()
                )
            }
            
        }
        //.offset(x: 20)
    }
}

struct RepeatButton_Previews: PreviewProvider {
    static var previews: some View {
        RepeatButton()
    }
}
