//
//  EditTopLevel.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct EditTopLevel: View {
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    var body: some View {
        
        HStack {
            VStack {
                Image("screenshot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 10)
            }
            .padding(.leading, 50)
            VStack {
                CaptionsListTitle()
                CaptionsList()
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
