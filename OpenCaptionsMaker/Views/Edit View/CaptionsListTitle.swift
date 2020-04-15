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
        HStack {
            Text("Timings")
            Spacer()
            Text("Caption")
            Spacer()
            Text("Speaker")
        }
        .font(.headline)
        .padding(.horizontal, 50)
    }
}

struct CaptionsListTitle_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListTitle()
    }
}
