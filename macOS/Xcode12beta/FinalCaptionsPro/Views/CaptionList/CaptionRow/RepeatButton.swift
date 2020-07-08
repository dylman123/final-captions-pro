//
//  RepeatButton.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 8/7/20.
//

import SwiftUI

struct RepeatButton: View {
    
    @EnvironmentObject var app: AppState
    private var isDisplayed: Bool {
        switch app.mode {
        case .play, .pause: return false
        case .edit, .editStartTime, .editEndTime: return true
        }
    }
    
    var body: some View {
        
        if isDisplayed {
            return AnyView (
                Button {
                    NotificationCenter.default.post(name: .playSegment, object: nil)
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
}

struct RepeatButton_Previews: PreviewProvider {
    static var previews: some View {
        RepeatButton()
    }
}
