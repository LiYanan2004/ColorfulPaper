//
//  SoundPlayer.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/3.
//

import AVKit

class SoundPlayer {
    private var player: AVPlayer = AVPlayer(url: Bundle.main.url(forResource: "sound", withExtension: "m4a")!)
    
    func play() {
        player.seek(to: .zero)
        player.play()
    }
}
