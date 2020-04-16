//
//  CaptionsList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsList: View {
    
    // Track the the selected caption
    @Binding var selectedCaption: Caption?
    
    var body: some View {
        
        // Dynamically read the list from captionData
        List(selection: $selectedCaption) {
            ForEach(captionData) { caption in
                    CaptionsListRow(caption: caption).tag(caption)
                        .padding(.vertical, 10)
            }
        }
    }
}

struct CaptionsList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsList(selectedCaption: .constant(captionData[0]))
    }
}
