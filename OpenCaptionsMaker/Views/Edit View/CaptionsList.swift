//
//  CaptionsList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsList: View {
    var body: some View {
        
        List(captionData) { (caption) -> CaptionsListRow in
            CaptionsListRow(caption: caption)
            
        }
        .cornerRadius(10)

    }
}

struct CaptionsList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsList()
    }
}
