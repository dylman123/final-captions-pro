//
//  CaptionRow.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionRow: View {
    
    // To refresh the UI when userData changes
    @EnvironmentObject var userDataEnvObj: UserData
    
    // The current caption binding
    var captionBinding: Binding<Caption> {
        return $userDataEnvObj.captions[captionIndex]
    }
    
    // Track selected caption
    var selectedCaption: Int
    
    // Logic to select caption
    var isSelected: Bool {
        if selectedCaption == captionIndex { return true }
        else { return false }
    }
    
    // Logic to edit caption
    var isEdited: Bool
        
    // Display caption color
    var rowColor: Color {
        if isSelected {
            if isEdited {
                return Color.green.opacity(0.5)
            } else { return Color.yellow.opacity(0.5) }
        }
        else {
            return Color.black.opacity(0.5)
        }
    }
    
    // The current caption object
    var caption: Caption
    
    // To index the current caption
    var captionIndex: Int {
        return userData.captions.firstIndex(where: { $0.id == caption.id }) ?? 0
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
        
        ZStack {
            
            // Row background
            RoundedRectangle(cornerRadius: 10).fill(rowColor)
            
            // Caption contents
            HStack(alignment: .center) {
                
                // Display caption timings
                VStack {
                    if isEdited && isSelected {
                        Stepper(value: captionBinding.start, step: -0.1) {
                            TextField("", value: captionBinding.start, formatter: timeFormatter)
                        }
                        Stepper(value: captionBinding.end, step: -0.1) {
                            TextField("", value: captionBinding.end, formatter: timeFormatter)
                        }
                    } else {
                        Text(String(caption.start))
                        Spacer()
                        Text(String(caption.end))
                    }
                }
                .frame(width: 80.0)
                
                Spacer()
                
                Text(caption.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: 300)
                    .offset(x: -30)
                
                Spacer()
                
                // Display insert plus and minus icons
                VStack {
                    
                    if isEdited {
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
                    } else {
                        Spacer()
                    }
                }
                .buttonStyle(buttonStyle)
                .padding(.trailing)
            }
        }
        .frame(height: 30)
    }
}

struct CaptionRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionRow(selectedCaption: 0, isEdited: false, caption: userData.captions[0])
            .frame(height: 100)
    }
}
