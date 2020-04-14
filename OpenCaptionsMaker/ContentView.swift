//
//  ContentView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 14/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    let windowWidth: CGFloat = 1600
    let windowHeight: CGFloat = 800
    
    var body: some View {
        
        HStack {
            Spacer()
            VStack {
                Text("Video will go here!")
            }
            
            Spacer()
            List {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
            .frame(width: windowWidth/2, height: windowHeight)
        }
        .frame(width: windowWidth, height: windowHeight)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
