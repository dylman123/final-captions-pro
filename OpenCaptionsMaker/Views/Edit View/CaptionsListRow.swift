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
        VStack {
            HStack(alignment: .center) {
                VStack {
                    Text(String(caption.start))
                    Spacer()
                    Text(String(caption.end))
                }
                Spacer()
                Text(caption.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                Text(caption.speakerName)
                    .multilineTextAlignment(.trailing)

            }
            .frame(height: 30)
            .padding(.horizontal)
            Divider()
        }
    }
}

struct CaptionsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListRow(caption: captionData[0])
    }
}
