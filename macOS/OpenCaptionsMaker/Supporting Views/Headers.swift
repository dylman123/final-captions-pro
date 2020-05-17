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

        VStack {
            ZStack {
                Text("Caption")
                HStack {
                    Text("Timings")
                    Spacer()
                }
            }
            Divider()
        }
    }
}

struct Headers_Previews: PreviewProvider {
    static var previews: some View {
        Headers()
    }
}
