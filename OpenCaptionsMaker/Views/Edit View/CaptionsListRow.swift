//
//  CaptionsListRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine

struct CaptionsListRow: View {
    
    // Write data back to model
    @EnvironmentObject var userData: UserData
    
    // To index the current caption
    var captionIndex: Int {
        userData.captions.firstIndex(where: { $0.id == caption.id })!
    }
    
    // The current caption object
    var caption: Caption
    
    // To format the time values in text
    var timeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    var body: some View {
        
        // Embed the contents & a divider in a VStack
        VStack {
            
            // Contents of the row
            HStack(alignment: .center) {
                
                // Display caption timings
                VStack {
                    TextField("", value: $userData.captions[self.captionIndex].start, formatter: timeFormatter)
                        
                    Spacer()
                    TextField("", value: $userData.captions[self.captionIndex].end, formatter: timeFormatter)
                }
                .frame(width: 50.0)
                Spacer()
                
                // Display caption text
                TextField("", text: $userData.captions[self.captionIndex].text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 300)
                Spacer()
                
                // Display speaker name
                TextField("", text: $userData.captions[self.captionIndex].speakerName)
                    .frame(width: 80.0)
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
            .environmentObject(UserData())
    }
}
