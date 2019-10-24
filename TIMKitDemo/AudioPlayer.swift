//
//  AudioPlayer.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation
import CommonTools

public protocol AudioPlayerDelegate: NSObject {
    func audioPlayer(_ audioPlayer: AudioPlayer, playStatus status: AudioPlayStatus)
}

public class AudioPlayer: NSObject, AVAudioPlayerDelegate {

    public var preparePlayer: ((AVAudioPlayer) -> Void)?
    private(set) public var audioURL: URL
    private(set) public var player: AVAudioPlayer?
    private var timer: Timer?
    private var currentTimeWhenInterrupted = 0.0
    private var isIntterupted = false
    public weak var delegate: AudioPlayerDelegate?
    private(set) public var stopTime: TimeInterval?
    public var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    public init(audioURL: URL) {
        self.audioURL = audioURL
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }

    // MARK: 处理音频播放中途被打断事件处理
    @objc private func handleInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
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


    /// 从指定事件播放音频
    /// - Parameter time: 播放开始时间点，如果为nil，默认从上次停止的时间点开始播放
    func play(atTime time: TimeInterval? = nil) throws {
        let player = try AVAudioPlayer(contentsOf: audioURL)
        if let time = time {
            player.currentTime = time
        } else {
            player.currentTime = stopTime ?? 0
        }
        player.delegate = self
        self.player = player
        delegate?.audioPlayer(self, playStatus: .prepare(player: player))
        preparePlayer?(player)
        let prepared = player.prepareToPlay()
        let playing = player.play()
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
            delegate?.audioPlayer(self, playStatus: .playProgress(current: Int(time), duration: Int(duration)))
        }
    }


    /// 停止播放
    public func stop() {
        timer?.invalidate()
        timer = nil
        if isPlaying {
            stopTime = player?.currentTime
            Log.i("上次停止时间\(stopTime)")
            player?.stop()
            delegate?.audioPlayer(self, playStatus: .stop(manual: true))
        }
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        timer = nil
        let duration = Int(ceil(player.duration - 0.1))
        delegate?.audioPlayer(self, playStatus: .playProgress(current: duration, duration: duration))
        delegate?.audioPlayer(self, playStatus: .stop(manual: false))
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
