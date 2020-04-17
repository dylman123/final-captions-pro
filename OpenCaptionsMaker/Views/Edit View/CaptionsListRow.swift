//
//  CaptionsListRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListRow: View {
    
    @Binding var id: Int?
    @Binding var start: Float?
    @Binding var end: Float?
    @Binding var duration: Float?
    @Binding var text: String?
    @Binding var speakerTag: Int?
    @Binding var speakerName: String?

    init(caption: Caption) {
        self.id = caption.id
        self.start = caption.start
        self.end = caption.end
        self.duration = caption.duration
        self.text = caption.text
        self.speakerTag = caption.speakerTag
        self.speakerName = caption.speakerName
    }
    
    var body: some View {
        
        // Embed the contents & a divider in a VStack
        VStack {
            
            // Contents of the row
            HStack(alignment: .center) {
                
                // Display caption timings
                VStack {
                    //TextField("", text: String($start))
                    Spacer()
                    //TextField("", text: String($end))
                }
                Spacer()
                
                // Display caption text
                TextField("", text: $text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 300)
                Spacer()
                
                // Display speaker name
                TextField("", text: $speakerName)
                    .multilineTextAlignment(.trailing)
                
                // Display insert plus icon
                VStack {
                    //NSImage(imageLiteralResourceName: "app.plus.fill")
                    Image("play")
                        //.resizable()
                        //.frame(width: 12, height: 12)
                        //.cornerRadius(3.0)
                    Spacer()
                }

            }
            .frame(height: 30)
            .padding(.leading)
            
            //Divider()
        }
    }
}

struct CaptionsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListRow(caption: captionData[0])
            .frame(height: 50)
    }
}
