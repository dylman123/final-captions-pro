//
//  UserInputView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct UserInputView: View {
    let windowWidth: CGFloat = 400
    let windowHeight: CGFloat = 600
    
    var body: some View {
        VStack {
            Text("Who are the speakers in this clip?")
                .font(.headline)
                .padding(.top, 50)
            List {
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
                Text("Add name")
            }
        }
    .frame(width: windowWidth, height: windowHeight)
    }
}

struct UserInputView_Previews: PreviewProvider {
    static var previews: some View {
        UserInputView()
    }
}
