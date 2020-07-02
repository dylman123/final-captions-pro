//
//  Sizer.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct Sizer: View {
    
    @Binding var size: CGFloat
    
    func updateSize(by step: CGFloat) -> Void {
        size += step
        let newSize = size
        if newSize < 10 { size = 10 }
        if newSize > 200 { size = 200 }
    }
    
    var body: some View {
        HStack {
            Button { updateSize(by: -5) } label: { Image(systemName: "chevron.down") }
            Button { updateSize(by: 5) } label: { Image(systemName: "chevron.up") }
        }
    }
}

struct Sizer_Previews: PreviewProvider {
    static var previews: some View {
        Sizer(size: .constant(20))
    }
}
