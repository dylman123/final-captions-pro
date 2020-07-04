//
//  Headers.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
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
