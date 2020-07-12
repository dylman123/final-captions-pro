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
    let numCaptionsOnPage: Int = 12
    
    func goToIndex(target: Int) {
        
        // Check if the target index is on a new page
        let distanceToNextPage = numCaptionsOnPage - (app.selectedIndex % numCaptionsOnPage)
        let distanceToPrevPage = distanceToNextPage - numCaptionsOnPage
        let delta = target - app.selectedIndex
        let isOnFuturePage: Bool = (delta >= distanceToNextPage)
        let isOnPrevPage: Bool = (delta < distanceToPrevPage)
        
        // Scroll to new target index
        if isOnFuturePage {
            NotificationCenter.default.post(name: .nextPage, object: target)
        }
        if isOnPrevPage {
            NotificationCenter.default.post(name: .prevPage, object: target)
        }
        
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
                    self.app.captions[self.app.selectedIndex].style = copiedStyle
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
                    self.app.captions[self.app.selectedIndex].style = newStyle
                    self.app.styles.append(newStyle)
                }
            }
        }
        // Remove tag
        else {
            let symbol = self.app.captions[self.app.selectedIndex].style.symbol
            
            // Disassociate tag from caption
            self.app.captions[self.app.selectedIndex].style = defaultStyle()
            
            
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
        NotificationCenter.default.post(name: .updateStyle, object: nil)
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
                        .id(caption.id)
                }
                .onReceive(NotificationCenter.default.publisher(for: .nextPage)) { target in
                    guard target.object != nil else { return }
                    let scrollTarget = target.object as! Int
                    withAnimation {
                        value.scrollTo(scrollTarget, anchor: .top)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .prevPage)) { target in
                    guard target.object != nil else { return }
                    let scrollTarget = target.object as! Int
                    withAnimation {
                        value.scrollTo(scrollTarget, anchor: .bottom)
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
            case .edit: self.tag(withSymbol: key)
            case .editStartTime: self.tag(withSymbol: key)  // TODO: Manipulate float as a string
            case .editEndTime: self.tag(withSymbol: key)  // TODO: Manipulate float as a string
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause:
                self.incrementSelectedIndex();
                app.isListControlling = true
            case .edit:
                self.incrementSelectedIndex();
                app.isListControlling = true
                NotificationCenter.default.post(name: .edit, object: nil)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: -0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .upArrow)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause:
                self.decrementSelectedIndex();
                app.isListControlling = true
            case .edit:
                self.decrementSelectedIndex();
                app.isListControlling = true
                NotificationCenter.default.post(name: .edit, object: nil)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
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
            case .edit: self.app.transition(to: .pause)
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
            default:
                if self.isTagged { self.tag(withSymbol: nil) }
                else { self._deleteCaption() }
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
        .onReceive(app.$videoPos) { _ in
            guard app.isListControlling == false else { return }
            let timestamp = app.videoPos * app.videoDuration
            let newIndex = app.captions.firstIndex(where: { Double($0.end) >= timestamp }) ?? 0
            goToIndex(target: newIndex)
        }
    }
}

struct CaptionList_Previews: PreviewProvider {
    static var previews: some View {
        CaptionList()
    }
}
