//
//  CaptionsListTitle.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListTitle: View {
    var body: some View {
        VStack {
            HStack {
                Text("Timings")
                Spacer()
                Text("Caption").offset(x: -10)
                Spacer()
                Text("Speaker")
            }
            .font(.body)
        }
        .padding(.horizontal)
    }
}

struct CaptionsListTitle_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListTitle()
    }
}
