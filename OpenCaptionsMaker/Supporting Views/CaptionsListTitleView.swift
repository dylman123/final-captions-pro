//
//  CaptionsListTitleView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListTitleView: View {
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

struct CaptionsListTitleView_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListTitleView()
    }
}
