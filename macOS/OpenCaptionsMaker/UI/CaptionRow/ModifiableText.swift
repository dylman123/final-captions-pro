//
//  ModifiableText.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 22/6/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

enum Direction { case left, right }

class TextModifier: ObservableObject {
    
    @Published var cursor: Int
    @Published var text: String
    
    func updateCursor(_ dir: Direction) {
        text.remove(at: text.index(text.startIndex, offsetBy: cursor))
        switch dir {
        case .left: cursor -= 1
        case .right: cursor += 1
        }
        text.insert("|", at: text.index(text.startIndex, offsetBy: cursor))
    }
    
    func moveCursor(_ dir: Direction) {
        switch dir {
        case .left:
            if cursor - 1 > 0 { updateCursor(.left) }
            else { cursor = 0 }
        case .right:
            if cursor + 1 < text.count - 2 { updateCursor(.right) }
            else { cursor = text.count - 2 }
        }
        print(cursor, "max: ", text.count)
    }
    
    init(_ text: String) {
        self.cursor = text.count
        self.text = text
        self.text.insert("|", at: text.index(text.startIndex, offsetBy: cursor))
    }
}

struct ModifiableText: View {
    
    @EnvironmentObject var app: AppState
    var row: RowState
    
    init(_ row: RowState) {
        self.row = row
    }
    
    func insertCharacter(_ char: String) {
        var text = app.captions[app.selectedIndex].text
        text.insert(contentsOf: char, at: text.index(text.startIndex, offsetBy: row.modifier.cursor+1))
        app.captions[app.selectedIndex].text = text
        row.modifier.updateCursor(.right)
    }
    
    func deleteCharacter() {
        guard row.modifier.cursor >= 0 else { return }
        var text = self.app.captions[self.app.selectedIndex].text
        text.remove(at: text.index(text.startIndex, offsetBy: row.modifier.cursor))
        self.app.captions[self.app.selectedIndex].text = text
        row.modifier.updateCursor(.left)
    }
    
    var body: some View {
        Text(row.modifier.text)
        .onReceive(NotificationCenter.default.publisher(for: .leftArrow)) { _ in
            guard self.app.mode == .edit else { return }
            self.row.modifier.moveCursor(.left)
        }
        .onReceive(NotificationCenter.default.publisher(for: .rightArrow)) { _ in
            guard self.app.mode == .edit else { return }
            self.row.modifier.moveCursor(.right)
        }
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard self.app.mode == .edit else { return }
            guard notification.object != nil else { return }
            let key = notification.object as! String
            self.insertCharacter(key)
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            guard self.app.mode == .edit else { return }
            self.insertCharacter(" ")
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            guard self.app.mode == .edit else { return }
            guard notification.object != nil else { return }
            let key = notification.object as! String
            self.insertCharacter(key)
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            guard self.app.mode == .edit else { return }
            guard notification.object != nil else { return }
            let key = notification.object as! String
            self.insertCharacter(key)
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            guard self.app.mode == .edit else { return }
            self.deleteCharacter()
        }
    }
}

struct ModifiableText_Previews: PreviewProvider {
    static var previews: some View {
        ModifiableText(RowState())
    }
}
