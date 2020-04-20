//
//  Headers.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Headers: View {
    var body: some View {

        HStack(alignment: .center, spacing: 190.0) {
                Text("Timings")
                Text("Caption")
                Spacer()
            }
        .font(.subheadline)
        .padding(.horizontal, 10)
    }
}

struct Headers_Previews: PreviewProvider {
    static var previews: some View {
        Headers()
    }
}
