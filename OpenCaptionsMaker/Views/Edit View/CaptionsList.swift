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
        List {
            CaptionsListRow(caption: captionData[0]).padding(.bottom)
            CaptionsListRow(caption: captionData[1]).padding(.bottom)
            CaptionsListRow(caption: captionData[2]).padding(.bottom)
        }
        .cornerRadius(10)
        .padding(.horizontal, 30)

    }
}

struct CaptionsList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsList()
    }
}
