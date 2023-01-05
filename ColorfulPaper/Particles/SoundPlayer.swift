//
//  SoundPlayer.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/3.
//

import AVKit

class SoundPlayer {
    private var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "sound", withExtension: "m4a")!)
#if os(iOS)
    private let session = AVAudioSession.sharedInstance()
#endif
    
#if os(iOS)
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
#endif
    
    func play() {
#if os(iOS)
        try? session.setCategory(.ambient, options: .duckOthers)
#endif
        player.seek(to: .zero)
        player.play()
    }
    
#if os(iOS)
    @objc func playerItemFinished() {
        try? session.setActive(false)
    }
#endif
}
