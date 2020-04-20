//
//  MySVGView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 17/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//
//  Attempt to render SVG in SWiftUI

import SwiftUI

struct MySVGView: View {

    var svgName: String

    var body: some View {
        SVGImage(svgName: self.svgName)
            .frame(width: 50, height: 550)
    }
}

struct SVGImage: NSViewRepresentable {

    var svgName: String

    func makeNSView(context: Context) -> SVGView {
        let svgView = MySVGView(svgName: svgName)
        svgView.backgroundColor = NSColor(white: 1.0, alpha: 0.0)   // otherwise the background is black
        svgView.fileName = self.svgName
        svgView.contentMode = .scaleToFill
        return svgView
    }

    func updateNSView(_ nsView: SVGView, context: Context) {

    }

}

struct MySVGView_Previews: PreviewProvider {
    static var previews: some View {
        MySVGView(svgName: "plus")
    }
}
