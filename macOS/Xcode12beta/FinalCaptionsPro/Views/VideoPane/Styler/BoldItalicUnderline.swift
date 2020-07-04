//
//  BoldItalicUnderline.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct BoldItalicUnderline: View {
    
    @Binding var bold: Bool
    @Binding var italic: Bool
    @Binding var underline: Bool
    
    var body: some View {
        HStack {
            Button { bold.toggle() } label: { Image(systemName: "bold") }
            Button { italic.toggle() } label: { Image(systemName: "italic") }
            Button { underline.toggle() } label: { Image(systemName: "underline") }
        }
    }
}

struct BoldItalicUnderline_Previews: PreviewProvider {
    static var previews: some View {
        BoldItalicUnderline(bold: .constant(false), italic: .constant(false), underline: .constant(false))
    }
}
