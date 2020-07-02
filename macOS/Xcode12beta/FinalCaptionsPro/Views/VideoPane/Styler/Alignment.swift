//
//  Alignment.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct Alignment: View {
    
    @Binding var alignment: TextAlignment
    
    var body: some View {
        HStack {
            Button { alignment = .leading } label: { Image(systemName: "text.justifyleft") }
            Button { alignment = .center } label: { Image(systemName: "text.justify") }
            Button { alignment = .trailing } label: { Image(systemName: "text.justifyright") }
        }
    }
}

struct Alignment_Previews: PreviewProvider {
    static var previews: some View {
        Alignment(alignment: .constant(.center))
    }
}
