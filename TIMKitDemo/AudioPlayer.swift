//
//  AudioPlayer.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    public var preparePlayer: ((AVAudioPlayer) -> Void)?
    public var onTimeChanged: ((Int, Int) -> Void)?
    private var audioURL: URL
    private(set) public var player: AVAudioPlayer?
    private var timer: Timer?
    private(set) public var isPlaying = false
    private var currentTimeWhenInterrupted = 0.0
    private var isIntterupted = false
    public var delegate: AVAudioPlayerDelegate?
    
    init(audioURL: URL) {
        self.audioURL = audioURL
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    // MARK: 处理音频播放中途被打断事件处理
    @objc private func handleInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else  {
                Log.i("接收到打断事件")
                return
        }
        if type == .began {
            Log.i("音频播放被打断……began")
            isIntterupted = true
            currentTimeWhenInterrupted = player?.currentTime ?? 0
            player?.pause()
        }
        if type == .ended, let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            isIntterupted = false
            Log.i("音频播放被打断……end")
            if options.contains(.shouldResume) {
                Log.i("恢复播放……")
                player?.currentTime = currentTimeWhenInterrupted
                player?.play()
            } else {
                Log.i("停止播放……")
                stop()
            }
        }
    }
    
    func play() throws {
        let player = try AVAudioPlayer(contentsOf: audioURL)
        player.delegate = self
        self.player = player
        preparePlayer?(player)
        let prepared = player.prepareToPlay()
        let playing = player.play()
        self.isPlaying = playing
        if prepared, playing {
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        } else {
            throw PlayerError.failed
        }
    }
    
    @objc private func tick() {
        if isIntterupted {
            Log.i("音频播放被打断……")
            return
        }
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
            delegate?.audioPlayerDidFinishPlaying?(player!, successfully: true)
            self.player?.stop()
        }
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
        isPlaying = false
        delegate?.audioPlayerDidFinishPlaying?(player, successfully: flag)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
