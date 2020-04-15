//
//  CaptionsListRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListRow: View {
    
    var caption: Caption
    
    var body: some View {
        HStack {
            VStack {
                Text(String(caption.start))
                Text(String(caption.end))
            }
            Spacer()
            Text(caption.text)
            Spacer()
            Text(caption.speakerName)
        }
    }
}

struct CaptionsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListRow(caption: captionData[0])
    }
}
