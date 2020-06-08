//
//  VideoPlayer.swift
//  AVPlayer-SwiftUI
//
//  Created by Chris Mash on 11/09/2019.
//  Copyright © 2019 Chris Mash. All rights reserved.
//
import SwiftUI
import Foundation
import AVFoundation
import AVKit

// This is the NSView that contains the AVPlayerLayer for rendering the video
class VideoPlayerNSView: NSView {
    private let player: AVPlayer
    private let playerLayer = AVPlayerLayer()
    private let videoPos: Binding<Double>
    private let videoDuration: Binding<Double>
    private let seeking: Binding<Bool>
    private var durationObservation: NSKeyValueObservation?
    private var timeObservation: Any?
  
    init(player: AVPlayer, videoPos: Binding<Double>, videoDuration: Binding<Double>, seeking: Binding<Bool>) {
        self.player = player
        self.videoDuration = videoDuration
        self.videoPos = videoPos
        self.seeking = seeking
        
        super.init(frame: .zero)
        _ = NSView.BackgroundStyle(rawValue: 0)
        playerLayer.player = player
        if layer == nil {
            layer = CALayer()
        }
        layer?.addSublayer(playerLayer)
        
        // Observe the duration of the player's item so we can display it
        // and use it for updating the seek bar's position
        durationObservation = player.currentItem?.observe(\.duration, changeHandler: { [weak self] item, change in
            guard let self = self else { return }
            self.videoDuration.wrappedValue = item.duration.seconds
        })
        
        // Observe the player's time periodically so we can update the seek bar's
        // position as we progress through playback
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self else { return }
            // If we're not seeking currently (don't want to override the slider
            // position if the user is interacting)
            guard !self.seeking.wrappedValue else {
                return
            }
        
            // update videoPos with the new video time (as a percentage)
            self.videoPos.wrappedValue = time.seconds / self.videoDuration.wrappedValue
        }
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    override func layout() {
        super.layout()
        playerLayer.frame = bounds
    }
    
    func cleanUp() {
        // Remove observers we setup in init
        durationObservation?.invalidate()
        durationObservation = nil
        
        if let observation = timeObservation {
            player.removeTimeObserver(observation)
            timeObservation = nil
        }
    }
  
}

// This is the SwiftUI view which wraps the AppKit-based PlayerNSView above
struct VideoPlayerPaneView: NSViewRepresentable {
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<VideoPlayerPaneView>) {
        // This function gets called if the bindings change, which could be useful if
        // you need to respond to external changes, but we don't in this example
    }
    
    func makeNSView(context: NSViewRepresentableContext<VideoPlayerPaneView>) -> NSView {
        let nsView = VideoPlayerNSView(player: player,
                                       videoPos: $videoPos,
                                       videoDuration: $videoDuration,
                                       seeking: $seeking)
        return nsView
    }
    
    static func dismantleNSView(_ nsView: NSView, coordinator: ()) {
        guard let playerNSView = nsView as? VideoPlayerNSView else {
            return
        }
        
        playerNSView.cleanUp()
    }
}

class Utility: NSObject {
    
    private static var timeHMSFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
    
    static func formatSecondsToHMS(_ seconds: Double) -> String {
        return timeHMSFormatter.string(from: seconds) ?? "00:00"
    }
    
}

// This is the SwiftUI view that contains the controls for the player
struct VideoPlayerControlsView : View {
    
    // Handle app
    @EnvironmentObject var app: AppState
    
    @Binding private(set) var videoPos: Double
    @Binding private(set) var videoDuration: Double
    @Binding private(set) var seeking: Bool
    
    let player: AVPlayer
    
    @State private var playerPaused: Bool = true
    
    var body: some View {
        HStack {
            // Play/pause button
            Button(action: togglePlayPause) {
                if playerPaused { IconView("NSTouchBarPlayTemplate") }
                else { IconView("NSTouchBarPauseTemplate") }
            }
            // Current video time
            Text("\(Utility.formatSecondsToHMS(videoPos * videoDuration))")
            // Slider for seeking / showing video progress
            Slider(value: $videoPos, in: 0...1, onEditingChanged: sliderEditingChanged)
            // Video duration
            Text("\(Utility.formatSecondsToHMS(videoDuration))")
            // Seek -15 seconds button
            Button(action: seekBack15) {
                IconView("NSTouchBarSkipBack15SecondsTemplate")
            }
            // Seek +15 seconds button
            Button(action: seekAhead15) {
                IconView("NSTouchBarSkipAhead15SecondsTemplate")
            }
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .onReceive(NotificationCenter.default.publisher(for: .play)) { _ in
            self.pausePlayer(false)
        }
        .onReceive(NotificationCenter.default.publisher(for: .pause)) { _ in
            self.pausePlayer(true)
        }
        .onReceive(NotificationCenter.default.publisher(for: .leftArrow)) { _ in
            switch self.app.mode {
            case .play, .pause: self.seekBack15()
            case .edit, .editStartTime, .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .rightArrow)) { _ in
            switch self.app.mode {
            case .play, .pause: self.seekAhead15()
            case .edit, .editStartTime, .editEndTime: ()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .seekVideo)) { newPos in
            self.seek(to: newPos.object as! Double, isListControlling: true)
        }
    }
    
    private func seekBack15() -> Void {
        seek(to: videoPos - 15.0 / videoDuration, isListControlling: false)
    }
    
    private func seekAhead15() -> Void {
        seek(to: videoPos + 15.0 / videoDuration, isListControlling: false)
    }
    
    private func seek(to newPos: Double, isListControlling: Bool) -> Void {
        switch isListControlling {
        case true: ()
        case false: sliderEditingChanged(editingStarted: true)
        }
        
        if newPos < 0 { videoPos = 0 }
        else if newPos > 1 { videoPos = 1 }
        else { videoPos = newPos }
        
        switch isListControlling {
        case true: listEditingChanged()
        case false: sliderEditingChanged(editingStarted: false)
        }
        
    }
    
    private func togglePlayPause() {
        if playerPaused {
            app.transition(to: .play)
        } else {
            app.transition(to: .pause)
        }
    }
    
    private func pausePlayer(_ pause: Bool) {
        playerPaused = pause
        if playerPaused {
            player.pause()
        } else {
            player.play()
        }
    }
    
    private func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // Set a flag stating that we're seeking so the slider doesn't
            // get updated by the periodic time observer on the player
            seeking = true
            app.transition(to: .pause)
        }
        
        // Do the seek if we're finished
        if !editingStarted {
            let targetTime = CMTime(seconds: videoPos * videoDuration, preferredTimescale: 600)
            player.seek(to: targetTime) { _ in
                // Now the seek is finished, resume normal operation
                self.seeking = false
                //app.transition(to: .play)
                self.app.syncVideoAndList(isListControlling: false)
            }
        }
    }
    
    private func listEditingChanged() {
        // If the list is controlling the seek, we can assume that the
        // app mode is .pause or .edit
        let targetTime = CMTime(seconds: videoPos * videoDuration, preferredTimescale: 600)
        player.seek(to: targetTime)
    }
}

// This is the SwiftUI view which contains the player and its controls
struct VideoPlayerContainerView : View {
    
    @EnvironmentObject var app: AppState
    private var index: Int { app.selectedIndex }
    private var caption: Caption { app.captions[index] }
    
    // Whether we're currently interacting with the seek bar or doing a seek
    @State private var seeking = false
    
    private let player: AVPlayer
  
    init(url: URL) {
        player = AVPlayer(url: url)
    }

    var body: some View {
        VStack {
            ZStack {
                VideoPlayerPaneView(videoPos: $app.videoPos,
                                videoDuration: $app.videoDuration,
                                seeking: $seeking,
                                player: player)
                VisualOverlay()
            }
            VideoPlayerControlsView(videoPos: $app.videoPos,
                                    videoDuration: $app.videoDuration,
                                    seeking: $seeking,
                                    player: player)
        }
        .onDisappear {
            // When this View isn't being shown anymore stop the player
            self.player.replaceCurrentItem(with: nil)
        }
    }
}

// This is the main SwiftUI view for this app, containing a single PlayerContainerView
struct VideoPlayer: View {
    var url: URL?
    
    init(url: URL?) {
        guard url != nil else { return }
        self.url = url!
    }
    var body: some View {
        VideoPlayerContainerView(url: self.url!)
    }
}

struct VideoPlayer_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer(url: URL(string: ""))
    }
}
