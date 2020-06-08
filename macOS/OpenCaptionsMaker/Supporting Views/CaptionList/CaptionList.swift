//
//  CaptionList.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 15/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI

struct CaptionList: View {
    
    // Handle app state
    @EnvironmentObject var app: AppState
    
    // Scroll logic
    @State private var scrollOffset = CGPoint(x: 0.0, y: 0.0)
    @State private var scrollBinding: Binding<CGPoint> = .constant(.zero)
    let scrollAmount: CGFloat = 45.0
    let numCaptionsOnPage: Int = 12

    func turnPages(quantity numPages: Int) -> Void {
        scrollOffset.y += scrollAmount * CGFloat(numCaptionsOnPage * numPages)
    }
    
    func goToIndex(target: Int) {
        // Check if the target index is on a new page
        let distanceToNextPage = numCaptionsOnPage - (app.selectedIndex % numCaptionsOnPage)
        let distanceToPrevPage = distanceToNextPage - numCaptionsOnPage
        let delta = target - app.selectedIndex
        let isOnFuturePage: Bool = (delta >= distanceToNextPage)
        let isOnPrevPage: Bool = (delta < distanceToPrevPage)
        
        // Count the number of pages to turn
        var numPagesToTurn: Int {
            if delta > 0 && delta <= numCaptionsOnPage { return 1 }
            else if delta > numCaptionsOnPage { return delta / numCaptionsOnPage }
            else if delta < 0 && delta >= -numCaptionsOnPage { return -1 }
            else if delta < -numCaptionsOnPage { return delta / numCaptionsOnPage }
            else { return 0 }
        }
        
        // If applicable, turn to the relevant page
        if isOnFuturePage || isOnPrevPage {
            withAnimation { turnPages(quantity: numPagesToTurn) }
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
            app.captions[app.selectedIndex].startTime += delta
        } else if app.mode == .editEndTime {
            app.captions[app.selectedIndex].endTime += delta
        }
    }
    
    func modifyEndTime(byStepSize delta: Float) -> Void {
        app.captions[app.selectedIndex].endTime += delta
    }
    
    func _addCaption() -> Void {
        app.captions = addCaption(toArray: app.captions, beforeIndex: app.selectedIndex, atTime: app.captions[app.selectedIndex].startTime)
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
    
    func insertCharacter(_ char: String) -> Void {
        app.captions[app.selectedIndex].text += char
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
                    let font = self.app.captions[self.app.selectedIndex].style.font
                    let xPos = self.app.captions[self.app.selectedIndex].style.xPos
                    let yPos = self.app.captions[self.app.selectedIndex].style.yPos
                    let alignment = self.app.captions[self.app.selectedIndex].style.alignment
                    let newStyle = Style (
                        symbol: symbol,
                        font: font,
                        xPos: xPos,
                        yPos: yPos,
                        alignment: alignment
                    )
                    self.app.captions[self.app.selectedIndex].style = newStyle
                    //newStyle.symbol = symbol
                    self.app.styles.append(newStyle)
                }
            }
        }
        // Remove tag
        else {
            let symbol = self.app.captions[self.app.selectedIndex].style.symbol
            
            // Disassociate tag from caption
            let defaultStyle = Style (
                symbol: symbolD,
                font: fontD,
                xPos: xPosD,
                yPos: yPosD,
                alignment: alignmentD
            )
            self.app.captions[self.app.selectedIndex].style = defaultStyle
            
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
        for style in app.styles { print("STYLE: \(String(describing: style.symbol))") }
        print("COUNT: \(app.styles.count)")
    }
    
    //init() {
    //    scrollBinding = scrollOffset as Binding<CGPoint>
    //}
    
    var body: some View {
        
        OffsetScrollView(.vertical, offset: $scrollOffset) {
        //ScrollView(.vertical) {
        //List {
            ForEach(app.captions) { caption in
                Row(self.app, caption)
                    .tag(caption)
                    .padding(.vertical, 5)
                    //.offset(y: self.scrollOffset)
            }
        }
        
        //}
        //.content.offset(y: self.scrollOffset)
        
        // Keyboard press logic
        .onReceive(NotificationCenter.default.publisher(for: .character)) { notification in
            guard notification.object != nil else { return }
            let key = notification.object as! String
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.tag(withSymbol: key)
            case .edit: self.insertCharacter(key)
            case .editStartTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.app.captions[self.app.selectedIndex].startTime)
                //strVal += String(describing: notification.object!)
                //self.app.captions[self.app.selectedIndex].startTime = (strVal as NSString).floatValue
            case .editEndTime: ()  // TODO: Manipulate float as a string
                //var strVal = String(self.app.captions[self.app.selectedIndex].endTime)
                //strVal += String(describing: notification.object!)
                //self.app.captions[self.app.selectedIndex].endTime = (strVal as NSString).floatValue
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
            case .edit: self.insertCharacter(notification.object as! String)
            case .editStartTime, .editEndTime: self.modifyTimeVal(byStepSize: 0.1)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .minus)) { notification in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self._deleteCaption()
            case .edit: self.insertCharacter(notification.object as! String)
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
                if self.app.captions[self.app.selectedIndex].style.symbol != nil { self.tag(withSymbol: nil) }
                else { self._deleteCaption() }
            case .edit: _ = self.app.captions[self.app.selectedIndex].text.popLast()
            case .editStartTime: ()
            case .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .spacebar)) { _ in
            switch self.app.mode {
            case .play: self.app.transition(to: .pause)
            case .pause: self.app.transition(to: .play)
            case .edit: self.insertCharacter(" ")
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
