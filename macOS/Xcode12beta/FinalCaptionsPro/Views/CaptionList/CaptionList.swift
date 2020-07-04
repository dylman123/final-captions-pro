//
//  CaptionList.swift
//  FinalCaptionsPro
//
//  Created by Dylan Klein on 30/6/20.
//

import SwiftUI

struct CaptionList: View {
    
    // Handle app state
    @EnvironmentObject var app: AppState
    
    func goToIndex(target: Int) {
        // Scroll to new target index
        NotificationCenter.default.post(name: .scroll, object: target)
        // Set the new selectedIndex
        app.selectedIndex = target
    }
    
    func incrementSelectedIndex() -> Void {
        // Guard against when last caption is selected
        guard app.selectedIndex < app.captions.count - 1 else { return }
        goToIndex(target: app.selectedIndex + 1)
    }
    
    func decrementSelectedIndex() -> Void {
        // Guard against when first caption is selected
        guard self.app.selectedIndex > 0 else { return }
        goToIndex(target: app.selectedIndex - 1)
    }
    
    func modifyTimeVal(byStepSize delta: Float) -> Void {
        if app.mode == .editStartTime {
            app.captions[app.selectedIndex].start += delta
        } else if app.mode == .editEndTime {
            app.captions[app.selectedIndex].end += delta
        }
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        app.captions[app.selectedIndex].end += delta
    }
    
    func _addCaption() -> Void {
        app.captions = addCaption(toArray: app.captions, beforeIndex: app.selectedIndex, atTime: app.captions[app.selectedIndex].start)
    }
    
    func _deleteCaption() -> Void {
        // Guard against only 1 caption remaining
        guard app.captions.count > 1 else { return }
        app.captions = deleteCaption(fromArray: app.captions, atIndex: app.selectedIndex)
        
        // If the last row is deleted, decrement app.selectedIndex
        if app.selectedIndex-1 == app.captions.count-1 {
            decrementSelectedIndex()
        }
    }
    
    func tag(withSymbol key: String?) -> Void {
        
        // New tag
        if key != nil {
            let char = Character(key!)
            if char.isLetter == true {
                let symbol = key!.uppercased()
                
                // Check if style already exists
                var styleExists = false
                for style in app.styles {
                    if style.symbol == symbol { styleExists = true }
                }
                
                // If style already exists, copy the style to the current caption
                if styleExists {
                    guard let index = app.styles.firstIndex(where: { $0.symbol == symbol }) else { return }
                    let copiedStyle = app.styles[index]
                    withAnimation {
                        self.app.captions[self.app.selectedIndex].style = copiedStyle
                    }
                }
                
                // If style does not exist, create a new style
                if !styleExists {
                    // Save caption current style to a tagged style
                    let newStyle = Style (
                        symbol: symbol,
                        font: self.app.captions[self.app.selectedIndex].style.font,
                        size: self.app.captions[self.app.selectedIndex].style.size,
                        color: self.app.captions[self.app.selectedIndex].style.color,
                        position: self.app.captions[self.app.selectedIndex].style.position,
                        alignment: self.app.captions[self.app.selectedIndex].style.alignment,
                        bold: self.app.captions[self.app.selectedIndex].style.bold,
                        italic: self.app.captions[self.app.selectedIndex].style.italic,
                        underline: self.app.captions[self.app.selectedIndex].style.underline
                    )
                    withAnimation {
                        self.app.captions[self.app.selectedIndex].style = newStyle
                    }
                    self.app.styles.append(newStyle)
                }
            }
        }
        // Remove tag
        else {
            let symbol = self.app.captions[self.app.selectedIndex].style.symbol
            
            // Disassociate tag from caption
            withAnimation {
                self.app.captions[self.app.selectedIndex].style = defaultStyle()
            }
            
            // Check if style needs to be deleted
            var styleIsShared = false
            for caption in app.captions {
                if caption.style.symbol == symbol { styleIsShared = true }
            }
            
            // Delete style from styles array
            if !styleIsShared {
                guard let index = app.styles.firstIndex(where: { $0.symbol == symbol }) else { return }
                app.styles.remove(at: index)
            }
        }
    }
    
    private var isTagged: Bool {
        if app.captions[app.selectedIndex].style.symbol != nil { return true }
        else { return false }
    }
    
    var body: some View {
        
        ScrollView(.vertical) {
            ScrollViewReader { value in
                
                ForEach(app.captions) { caption in
                    CaptionRow(caption: caption)
                        .tag(caption)
                        .padding(.vertical, 5)
                        //.environmentObject(RowState(caption))
                        .id(caption.id)
                }
                .onReceive(NotificationCenter.default.publisher(for: .scroll)) { target in
                    guard target.object != nil else { return }
                    let scrollTarget = target.object as! Int
                    withAnimation {
                        value.scrollTo(scrollTarget, anchor: .center)
                    }
                }
            }
        }
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            let key = notification.object as! String
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.tag(withSymbol: key)
            case .edit: ()
            case .editStartTime: ()  // TODO: Manipulate float as a string
            case .editEndTime: ()  // TODO: Manipulate float as a string
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .edit: self.incrementSelectedIndex(); self.app.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .edit: self.decrementSelectedIndex(); self.app.syncVideoAndList(isListControlling: true)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .plus)) { notification in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self._addCaption()
            case .edit: ()
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: ()
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .returnKey)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause, .editStartTime, .editEndTime: self.app.transition(to: .edit)
            case .edit: NotificationCenter.default.post(name: .downArrow, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .tab)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: ()
            case .edit: self.app.transition(to: .editStartTime)
            case .editStartTime: self.app.transition(to: .editEndTime)
            case .editEndTime: self.app.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .delete)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause:
                if self.isTagged { self.tag(withSymbol: nil) }
                else { self._deleteCaption() }
            case .edit: ()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.app.transition(to: .play)
            case .edit: ()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .escape)) { _ in
            switch self.app.mode {
            case .play, .edit: self.app.transition(to: .pause)
            case .pause: ()
            case .editStartTime, .editEndTime: self.app.transition(to: .edit)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .play)) { _ in
            DispatchQueue.global(qos: .background).async {
                while self.app.mode == .play {
                    self.app.syncVideoAndList(isListControlling: false)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .seekList)) { notification in
            let newIndex = notification.object as! Int
            
            // If the video playback has transitioned to the next caption
            if newIndex == self.app.selectedIndex + 1 {
                self.incrementSelectedIndex()
            }
                
            // If the video playback has not transitioned to the next caption
            else if newIndex == self.app.selectedIndex {}
            
            // If the video is seeking
            else {
                withAnimation { self.goToIndex(target: newIndex) }
            }
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
