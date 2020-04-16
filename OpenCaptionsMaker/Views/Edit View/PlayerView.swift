//
//  PlayerView.swift
//  OpenCaptionsMaker
//
//  Created by Dylan Klein on 16/4/20.
//  Copyright © 2020 Dylan Klein. All rights reserved.
//

import SwiftUI
import AVFoundation

// Contains both the player and controls views
//struct PlayerContainerView : View {
//
//    private let player: AVPlayer
//
//    init(player: AVPlayer) {
//        self.player = player
//    }
//
//    var body: some View {
//        VStack {
//            PlayerView(player: player)
//            PlayerControlsView(player: player)
//        }
//    }
//}
//
//// Converts an Appkit UI to SwiftUI
//struct PlayerView: NSViewRepresentable {
//
//    let player: AVPlayer
//
//    func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext<PlayerView>) {
//
//    }
//
//    func makeNSView(context: Context) -> NSView {
//        return PlayerNSView(player: player)
//    }
//}

// Describes the video player class
//class PlayerNSView: NSView {
//
//    private let playerLayer = AVPlayerLayer()
//
//    init(player: AVPlayer) {
//        super.init(frame: .zero)
//        player.play()
//        playerLayer.player = player
//        if layer == nil{
//            layer = CALayer()
//        }
//        layer?.addSublayer(playerLayer)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func layout() {
//        super.layout()
//        playerLayer.frame = bounds
//    }
//}
//
//// Describes the controls view
//struct PlayerControlsView : View {
//
//    @State var playerPaused = true
//    @State var seekPos = 0.0
//    let player: AVPlayer
//
//    init(player: AVPlayer) {
//        self.player = player
//
//        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { time in
//            guard let item = self.player.currentItem else {
//                return
//            }
//
//        self.seekPos = time.seconds / item.duration.seconds
//        }
//    }
//
//    var body: some View {
//        HStack {
//
//            Button(action: {
//                self.playerPaused.toggle()
//                if self.playerPaused {
//                    self.player.pause()
//                }
//                else {
//                    self.player.play()
//                }
//            }) {
//                Image(playerPaused ? "play.neg" : "pause.neg")
//                .padding(.leading, 20)
//                .padding(.trailing, 20)
//            }
//
//            Slider(value: $seekPos, in: 0...1, onEditingChanged: { _ in
//                guard let item = self.player.currentItem else {
//                    return
//                }
//                let targetTime = self.seekPos * item.duration.seconds
//                self.player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
//            })
//            .padding(.trailing, 20)
//        }
//    }
//}

//struct PlayerView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlayerView(player: AVPlayer(url: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!))
//    }
//}
