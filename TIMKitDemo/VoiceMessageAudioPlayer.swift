//
//  VoiceMessageAudioPlayer.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/22.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation

public protocol VoiceMessageAudioPlayerDelegate: NSObject {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, message: TIMMessage, successfully flag: Bool)
}

public class VoiceMessageAudioPlayer: AudioPlayer {
    private var message: TIMMessage
    public weak var messageAudioDelegate: VoiceMessageAudioPlayerDelegate?

    public init(audioURL: URL, message: TIMMessage) {
        self.message = message
        super.init(audioURL: audioURL)
    }

    public override func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate = nil
        super.audioPlayerDidFinishPlaying(player, successfully: flag)
        self.messageAudioDelegate?.audioPlayerDidFinishPlaying(player, message: message, successfully: flag)
    }
}
