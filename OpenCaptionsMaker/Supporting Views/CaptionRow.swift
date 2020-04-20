//
//  CaptionRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import Combine
import AppKit

struct CaptionRow: View {
    
    // Write data back to model
    @EnvironmentObject var userData: UserData
       
    // The current caption object
    var caption: Caption
    
    // To index the current caption
    var captionIndex: Int {
        return userData.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
    }
    
    // The current caption binding
    var captionBinding: Binding<Caption> {
        let captionIndex = userData.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
        return $userData.captions[captionIndex]
    }
    
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
                Stepper(value: self.captionBinding.start, step: -0.1) {
                    TextField("", value: self.captionBinding.start, formatter: timeFormatter)
                }
                Stepper(value: self.captionBinding.end, step: -0.1) {
                    TextField("", value: self.captionBinding.end, formatter: timeFormatter)
                }
            }
            .frame(width: 80.0)
            Spacer()
            
            // Display caption text
            TextField("", text: self.captionBinding.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 300)
            Spacer()
            
            // Display insert plus icon
            VStack {
                Button(action: {self.userData.addCaption(beforeIndex: self.captionIndex, atTime: self.caption.start)}) {
                    Image("plus")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 12, height: 12)
                        .colorInvert()
                }
                
                Button(action: {
                    self.userData.deleteCaption(atIndex: self.captionIndex)
                }) {
                    if self.userData.captions.count > 1 {  // Don't give option to delete when only 1 caption is in list
                        Image("minus")
                            .renderingMode(.original)
                            .resizable()
                            .frame(width: 12, height: 12)
                            .colorInvert()
                    }
                }
            }
            .buttonStyle(buttonStyle)
        }
        .frame(height: 30)
    }
}

struct CaptionRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionRow(caption: captionData[0])
            .frame(height: 50)
            .environmentObject(UserData())
    }
}
