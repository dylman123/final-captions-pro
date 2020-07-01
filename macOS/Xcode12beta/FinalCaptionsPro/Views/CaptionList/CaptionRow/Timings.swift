//
//  Timings.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct Timings: View {
    
    // Constants
    let timeWidth = CGFloat(100.0)
    let timePadding = CGFloat(20.0)
    
    // To format the time values in text
//    var timeFormatter: NumberFormatter {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 1
//        formatter.maximumFractionDigits = 1
//        return formatter
//    }
    
    // Variables
    @EnvironmentObject var row: RowState
    
    // The current caption binding (for stepper)
    var binding: Binding<Caption> {
        return $row.app.captions[row.index]
    }
    
    var body: some View {
        
        if row.isSelected {
        
            return AnyView(VStack {
                    
                // Start Time
                if row.app.mode == .editStartTime {
                    Stepper(value: binding.start, step: -0.1) {
                        ZStack {
                            Text(String(format: "%.1f", row.caption.start))
                                .clickable(row, fromView: .startTime)
                            SelectionBox()
                        }
                    }
                    .padding(.leading, timePadding)
                } else {
                    Text(String(format: "%.1f", row.caption.start))
                        .clickable(row, fromView: .startTime)
                }
                Spacer()
                
                // End Time
                if row.app.mode == .editEndTime {
                    Stepper(value: binding.end, step: -0.1) {
                        ZStack {
                            Text(String(format: "%.1f", row.caption.end))
                                .clickable(row, fromView: .endTime)
                            SelectionBox()
                        }
                    }
                    .padding(.leading, timePadding)
                } else {
                    Text(String(format: "%.1f", row.caption.end))
                        .clickable(row, fromView: .endTime)
                }
            }
            .frame(width: timeWidth))
        }
        
        else {
            
            // Display caption timings
            return AnyView(VStack {
                Text(String(format: "%.1f", row.caption.start))
                    .clickable(row, fromView: .startTime)
                Spacer()
                Text(String(format: "%.1f", row.caption.end))
                   .clickable(row, fromView: .endTime)
            }
            .frame(width: timeWidth))
        }
    }
}

struct Timings_Previews: PreviewProvider {
    static var previews: some View {
        Timings()
            .environmentObject(RowState())
    }
}
