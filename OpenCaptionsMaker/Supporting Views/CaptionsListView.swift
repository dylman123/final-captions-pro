//
//  CaptionsListView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListView: View {
    var body: some View {
        List {
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
            CaptionsListRowView().padding(.bottom)
        }
        .cornerRadius(20)
        .padding(.horizontal, 50)

    }
}

struct CaptionsListView_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListView()
    }
}
