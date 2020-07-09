//
//  ExportButton.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 9/7/20.
//

import SwiftUI

struct ExportButton: View {
    @EnvironmentObject var app: AppState
    @State private var showExportLabel: Bool = true
    
    // To do: Replace this with a save file dialog
    let testPath = getDocumentsDirectory().appendingPathComponent("test.fcpxml")
    
    var body: some View {
        
        // Finish review button
        HStack {
            Spacer()
            if showExportLabel { Text("Export to Final Cut Pro") }
            Button {
                finishReview(inAppState: self.app, andSaveFileAs: testPath)
            } label: {
                Image(systemName: "chevron.right")
            }
//            .onHover { _ in  // Constant hovering? A bug in Swift 5.3?
//                showExportLabel.toggle()
//                print(showExportLabel)
//            }
        }
        .offset(y: 20)
    }
}

struct ExportButton_Previews: PreviewProvider {
    static var previews: some View {
        ExportButton()
    }
}
