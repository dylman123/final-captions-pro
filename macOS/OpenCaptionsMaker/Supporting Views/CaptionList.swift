//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // Read/write data back to model
    @EnvironmentObject var userDataWriteable: UserData
    
    // Track the the selected caption
    @State private var selectedCaption = 0
    
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                ForEach(userDataWriteable.captions) { caption in
                    CaptionRow(selectedCaption: self.selectedCaption, caption: caption)
                    .tag(caption)
                    .padding(.vertical, 10)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .moveDown)) { _ in
            guard self.selectedCaption < userData.captions.count-1 else { return }
            self.selectedCaption += 1
            }
        .onReceive(NotificationCenter.default.publisher(for: .moveUp)) { _ in
            guard self.selectedCaption > 0 else { return }
            self.selectedCaption -= 1
            }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        //CaptionList(selectedCaption: .constant(sampleCaptionData[0]))
        CaptionList()
    }
}
