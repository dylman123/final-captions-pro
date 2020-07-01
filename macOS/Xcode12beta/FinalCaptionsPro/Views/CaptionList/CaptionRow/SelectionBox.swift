//
//  SelectionBox.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

// Draw a box when element is selected
struct SelectionBox: View {
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(Color.white, lineWidth: 2)
            )
    }
}

struct SelectionBox_Previews: PreviewProvider {
    static var previews: some View {
        SelectionBox()
    }
}
