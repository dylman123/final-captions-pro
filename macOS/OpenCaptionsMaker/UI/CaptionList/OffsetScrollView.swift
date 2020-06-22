//
//  OffsetScrollView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 27/5/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

public struct OffsetScrollView<Content>: View where Content : View {

    /// The content of the scroll view.
    public var content: Content

    /// The scrollable axes.
    ///
    /// The default is `.vertical`.
    public var axes: Axis.Set

    /// If true, the scroll view may indicate the scrollable component of
    /// the content offset, in a way suitable for the platform.
    ///
    /// The default is `true`.
    public var showsIndicators: Bool

    /// The initial offset of the view as measured in the global frame
    @State private var initialOffset: CGPoint?

    /// The offset of the scroll view updated as the scroll view scrolls
    @Binding public var offset: CGPoint

    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, offset: Binding<CGPoint> = .constant(.zero), @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self._offset = offset
        self.content = content()
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader { geometry in
                    Run {
                        let offset = self.$offset.wrappedValue
                        _ = geometry.frame(in: .global).offsetBy(dx: 0, dy: offset.y)
//                        let globalOrigin = geometry.frame(in: .global).origin
//                        self.initialOffset = self.initialOffset ?? globalOrigin
//                        let initialOffset = (self.initialOffset ?? .zero)
//                        let offset = CGPoint(x: globalOrigin.x - initialOffset.x, y: globalOrigin.y - initialOffset.y)
//                        self.$offset.wrappedValue = offset
                        
                    }
                }.frame(width: 0, height: 0)
                
                content
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: .nextPage)) { notification in
//            print("before: ", self._offset)
//            self._offset.y += notification.object as! Binding<CGFloat>
//            print("after: ", self._offset)
//        }
//        .onReceive(NotificationCenter.default.publisher(for: .prevPage)) { notification in
//
//        }
    }
    
    struct Run: View {
        let block: () -> Void

        var body: some View {
            DispatchQueue.main.async(execute: block)
            return AnyView(EmptyView())
        }
    }
}

struct OffsetScrollView_Previews: PreviewProvider {
    static var previews: some View {
        OffsetScrollView {
            Text("Hello World")
        }
    }
}
