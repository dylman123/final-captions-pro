//
//  EditTopLevel.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct EditTopLevel: View {
    
    //Set window sizes
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    // A variable to track the selected row
    @State private var selectedCaption: Caption?
    
    var body: some View {
        
        // Window view for edit screen
        HStack {
            
            //Video player
            VideoPlayer()
            //.frame(width: windowWidth/3)
            .padding(.leading, 50)
            
            // Captions list
            VStack {
                CaptionsListTitle()
                CaptionsList(selectedCaption: $selectedCaption)
            }
            .frame(width: windowWidth/2, height: windowHeight*0.8)
            .padding(.horizontal, 50)
        }
        .frame(width: windowWidth, height: windowHeight)
    }
}

struct EditTopLevel_Previews: PreviewProvider {
    static var previews: some View {
        EditTopLevel()
    }
}
