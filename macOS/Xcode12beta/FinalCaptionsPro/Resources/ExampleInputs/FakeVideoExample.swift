//
//  FakeVideoExample.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 1/7/20.
//

import SwiftUI

struct FakeVideoExample: View {
    var body: some View {
        
        VStack {
            
            // Visual pane
            Image("screenshot")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .shadow(radius: 10)
            
            // Playback options
            Text("Sliders and buttons")
        }
        
    }
}

struct FakeVideoExample_Previews: PreviewProvider {
    static var previews: some View {
        FakeVideoExample()
    }
}
