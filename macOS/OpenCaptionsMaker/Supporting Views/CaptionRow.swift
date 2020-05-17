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
    
    // Highlight if selected
    var selectedCaption: Int
    var isSelected: Bool {
        if selectedCaption == captionIndex {
            return true
        }
        else {
            return false
        }
    }
    var rowColor: Color {
        if isSelected { return Color.yellow.opacity(0.5) }
        else { return Color.black.opacity(0.5) }
    }

    // Write data back to model
    @EnvironmentObject var userDataWriteable: UserData
    
    // The current caption binding
    var captionBinding: Binding<Caption> {
        return $userDataWriteable.captions[captionIndex]
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
                
                // Display insert plus and minus icons
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
                .padding(.trailing)
            }
        }
        .frame(height: 30)
        .onReceive(NotificationCenter.default.publisher(for: .addCaption)) { _ in
            if self.isSelected {
                addCaption(beforeIndex: self.captionIndex, atTime: self.caption.start)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteCaption)) { _ in
            if (self.isSelected) && (userData.captions.count > 1) {  // Don't delete when only 1 caption is in list
                deleteCaption(atIndex: self.captionIndex)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .enterCharacter)) { notification in
            guard notification.object != nil else { return }
            print(notification.object!)
        }
    }
}

struct CaptionRow_Previews: PreviewProvider {
    static var previews: some View {
        CaptionRow(selectedCaption: 0, caption: userData.captions[0])
            .frame(height: 100)
    }
}
