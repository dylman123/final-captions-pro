//
//  ModifiableText.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 22/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

class TextModifier: ObservableObject {
    
    @Published var cursor: Int
    @Published var text: String
    var displayText: String {
        var array = Array(self.text)
        array.insert("|", at: cursor)
        return String(array)
    }
    
    init(_ text: String) {
        self.text = text
        self.cursor = text.count
    }
}

struct ModifiableText: View {
    
    @EnvironmentObject var app: AppState
    var row: RowState
    var modifier: TextModifier
    
    init(_ row: RowState) {
        self.row = row
        self.modifier = TextModifier(row.caption.text)
    }
    
    enum Direction { case left, right }
    func moveCursor(_ dir: Direction) {
        if dir == .left {
            if modifier.cursor <= 0 { modifier.cursor = 0 }
            else { modifier.cursor -= 1 }
        }
        else if dir == .right {
            if modifier.cursor >= modifier.displayText.count { modifier.cursor = modifier.displayText.count }
            else { modifier.cursor += 1 }
        }
        print(self.modifier.cursor)
    }
    
    var body: some View {
        Text(modifier.displayText)
        .onReceive(NotificationCenter.default.publisher(for: .leftArrow)) { _ in
            switch self.app.mode {
            case .play, .pause: ()
            case .edit: self.moveCursor(.left)
            case .editStartTime, .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .rightArrow)) { _ in
            switch self.app.mode {
            case .play, .pause: ()
            case .edit: self.moveCursor(.right)
            case .editStartTime, .editEndTime: ()
            }
        }
    }
}

struct ModifiableText_Previews: PreviewProvider {
    static var previews: some View {
        ModifiableText(RowState())
    }
}
