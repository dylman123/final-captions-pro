//
//  VideoPlayer.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct VideoPlayer: View {
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

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer()
    }
}
