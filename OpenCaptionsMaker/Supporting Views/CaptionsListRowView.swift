//
//  CaptionsListRowView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListRowView: View {
    var body: some View {
        HStack {
            VStack {
                Text("0.0")
                Text("1.3")
            }
            Spacer()
            Text("I'm fucking competitive")
            Spacer()
            Text("Daisy")
        }
    }
}

struct CaptionsListRowView_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListRowView()
    }
}
