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
                Stepper(value: captionBinding.start, step: -0.1) {
                    TextField("", value: captionBinding.start, formatter: timeFormatter)
                }
                Stepper(value: captionBinding.end, step: -0.1) {
                    TextField("", value: captionBinding.end, formatter: timeFormatter)
                }
            }
            .frame(width: 80.0)
            
            Spacer()
            
            // Display caption text
            TextField("", text: captionBinding.text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 300)
                .offset(x: -30)
            
            Spacer()
            
            // Display insert plus icon
            VStack {
                Button(action: {
                    addCaption(beforeIndex: self.captionIndex, atTime: self.caption.start)
                }) {
                    IconView("NSAddTemplate")
                        .frame(width: 12, height: 12)
                }

                Button(action: {
                    deleteCaption(atIndex: self.captionIndex)
                }) {
                    if userData.captions.count > 1 {  // Don't give option to delete when only 1 caption is in list
                        IconView("NSRemoveTemplate")
                        .frame(width: 12, height: 12)
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
        CaptionRow(caption: sampleCaptionData[0])
            .frame(height: 100)
    }
}
