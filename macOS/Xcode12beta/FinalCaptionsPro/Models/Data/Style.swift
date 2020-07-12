//
//  Style.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import Foundation
import SwiftUI

class Style: Hashable, Identifiable, Equatable, ObservableObject {
    let id: Int  // Random unique identifier of the style
    @Published var symbol: String?  // The symbol (alphabetical) associated with this style
    @Published var font: String
    @Published var size: CGFloat
    @Published var color: Color
    @Published var position: CGSize
    @Published var alignment: TextAlignment
    @Published var bold: Bool
    @Published var italic: Bool
    @Published var underline: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
    
    init(symbol: String?, font: String, size: CGFloat, color: Color, position: CGSize, alignment: TextAlignment, bold: Bool, italic: Bool, underline: Bool) {
        self.id = 0 //UUID()
        self.symbol = symbol
        self.font = font
        self.size = size
        self.color = color
        self.position = position
        self.alignment = alignment
        self.bold = bold
        self.italic = italic
        self.underline = underline
    }
}
// Need the following func to make Style conform to Equatable
func == (lhs: Style, rhs: Style) -> Bool {
    return lhs.symbol == rhs.symbol
}

func defaultStyle() -> Style {
    // Set default style params
    let _symbol: String? = nil
    let _font: String = "Arial"
    let _size: CGFloat = 30.0
    let _color: Color = .white
    let _position: CGSize = CGSize(width: 0.0, height: 150)
    let _alignment: TextAlignment = .center
    let _bold: Bool = false
    let _italic: Bool = false
    let _underline: Bool = false
    
    return Style (
        symbol: _symbol,
        font: _font,
        size: _size,
        color: _color,
        position: _position,
        alignment: _alignment,
        bold: _bold,
        italic: _italic,
        underline: _underline
    )
}
