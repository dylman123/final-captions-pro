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
        return userData.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
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
    
    // To format the plus button
    var buttonStyle = BorderlessButtonStyle()
    
    var body: some View {
            
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
                Button(action: {self.userData.addCaption(beforeIndex: self.captionIndex, atTime: self.userData.captions[self.captionIndex].start)}) {
                    Image("plus")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 15, height: 15)
                        .colorInvert()
                }
                
                Button(action: {
                    self.userData.deleteCaption(atIndex: self.captionIndex)
                }) {
                    if self.userData.captions.count > 1 {  // Don't give option to delete when only 1 caption is in list
                        Image("minus")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .colorInvert()
                    }
                }
            }
            .offset(x: 5)
            .buttonStyle(buttonStyle)
        }
        .frame(height: 30)
        .padding(.leading)
    }
}

struct CaptionsListRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionsListRow(caption: captionData[0])
            .frame(height: 50)
            .environmentObject(UserData())
    }
}
