//
//  CaptionsListRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionsListRow: View {
    
    var caption: Caption
    
    var body: some View {
        
        // Embed the contents & a divider in a VStack
        VStack {
            
            // Contents of the row
            HStack(alignment: .center) {
                
                // Display caption timings
                VStack {
                    Text(String(caption.start))
                    Spacer()
                    Text(String(caption.end))
                }
                Spacer()
                
                // Display caption text
                Text(caption.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                
                // Display speaker name
                Text(caption.speakerName)
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
