//
//  EditScreenView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct EditScreenView: View {
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    var body: some View {
        
        HStack {
            VStack {
                Image("screenshot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                    .shadow(radius: 10)
            }
            .padding(.leading, 50)
            VStack {
                CaptionsListTitleView()
                CaptionsListView()
            }
            .frame(width: windowWidth/2, height: windowHeight*0.8)
        }
        .frame(width: windowWidth, height: windowHeight)
    }
}

struct EditScreenView_Previews: PreviewProvider {
    static var previews: some View {
        EditScreenView()
    }
}
