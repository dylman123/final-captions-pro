//
//  Sizer.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 2/7/20.
//

import SwiftUI

struct sizeBounds {
    let min: CGFloat = 10
    let max: CGFloat = 200
}

struct Sizer: View {
    
    @Binding var size: CGFloat
    let bounds = sizeBounds()
    
    func updateSize(by step: CGFloat) -> Void {
        let relMin = bounds.min / bounds.max
        let relMax = bounds.max / bounds.max
        size += step / bounds.max
        let newSize = size
        if newSize < relMin { size = relMin }
        if newSize > relMax { size = relMax }
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
        Sizer(size: .constant(0.2))
    }
}
