//
//  Timings.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 3/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct Timings: View {
    
    // Constants
    let timeWidth = CGFloat(100.0)
    let timePadding = CGFloat(20.0)
    
    // To format the time values in text
    var timeFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    // Variables
    @EnvironmentObject var appState: AppState
    private var row: RowState  // An object to hold the state of the current row
    private var caption: Caption  // The caption object in the current row
    private var isSelected: Bool  // Is the current row selected?
    private var index: Int  // The current row's index in the list
    private var clickNumber: Int  // An integer to define clicking behaviour
    private var color: Color  // The current row's colour
    
    // The current caption binding (for stepper)
    var binding: Binding<Caption> {
        return $appState.captions[index]
    }
    
    init(_ row: RowState) {
        self.row = row
        self.caption = row.caption
        self.isSelected = row.isSelected
        self.index = row.index
        self.clickNumber = row.clickNumber
        self.color = row.color
    }
    
    var body: some View {
        
        if isSelected {
        
            return AnyView(VStack {
                    
                // Start Time
                if appState.mode == .editStartTime {
                    Stepper(value: binding.startTime, step: -0.1) {
                        ZStack {
                            Text(String(format: "%.1f", caption.startTime))
                                .clickable(row, fromView: .startTime)
                            SelectionBox()
                        }
                    }
                    .padding(.leading, timePadding)
                } else {
                    Text(String(format: "%.1f", caption.startTime))
                        .clickable(row, fromView: .startTime)
                }
                Spacer()
                
                // End Time
                if appState.mode == .editEndTime {
                    Stepper(value: binding.endTime, step: -0.1) {
                        ZStack {
                            Text(String(format: "%.1f", caption.endTime))
                                .clickable(row, fromView: .endTime)
                            SelectionBox()
                        }
                    }
                    .padding(.leading, timePadding)
                } else {
                    Text(String(format: "%.1f", caption.endTime))
                        .clickable(row, fromView: .endTime)
                }
            }
            .frame(width: timeWidth))
        }
        
        else {
            
            // Display caption timings
            return AnyView(VStack {
                Text(String(format: "%.1f", caption.startTime))
                    .clickable(row, fromView: .startTime)
                Spacer()
                Text(String(format: "%.1f", caption.endTime))
                   .clickable(row, fromView: .endTime)
            }
            .frame(width: timeWidth))
        }
    }
}

struct Timings_Previews: PreviewProvider {
    static var previews: some View {
        Timings(RowState(AppState(), Caption()))
    }
}
