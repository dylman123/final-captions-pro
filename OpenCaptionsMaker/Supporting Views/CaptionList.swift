//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // Read/write data back to model
    @EnvironmentObject var userData: UserData
    
    // Track the the selected caption
    @Binding var selectedCaption: Caption?
    
    var body: some View {
        
        // Dynamically read the list from userData
        List(selection: $selectedCaption) {
            ForEach(userData.captions) { caption in
                    CaptionRow(caption: caption).tag(caption)
                        .padding(.vertical, 10)
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList(selectedCaption: .constant(captionData[0]))
            .environmentObject(UserData())
    }
}
