//
//  AudioPlayer.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject {
    
    public var preparePlayer: ((AVAudioPlayer) -> Void)?
    public var onTimeChanged: ((Int, Int) -> Void)?
    private var audioURL: URL
    private(set) public var player: AVAudioPlayer?
    private var timer: Timer?
    
    init(audioURL: URL) {
        self.audioURL = audioURL
        super.init()
    }
    
    func play() throws {
        let player = try AVAudioPlayer(contentsOf: audioURL)
        self.player = player
        preparePlayer?(player)
        player.prepareToPlay()
        player.play()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc private func tick() {
        if let player = player {
            let currentTime = player.currentTime
            let time = ceil(currentTime - 0.1)
            let duration = ceil(player.duration - 0.1)
            onTimeChanged?(Int(duration), Int(time))
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        if let isPlaying = self.player?.isPlaying, isPlaying {
            self.player?.stop()
        }
    }
    
}
