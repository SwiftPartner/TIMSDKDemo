//
//  VoiceMessagePlayer.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/22.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import CommonTools
import coswift
import AVFoundation
import RxSwift

public enum AudioPlayStatus {

    case prepare(player: AVAudioPlayer)
    case startPlaying
    case downloading(progress: Int64, totalProgress: Int64)
    case stop(manual: Bool)
    case error(error: Error)
    case playProgress(current: Int, duration: Int)
}

public class VoiceMessagePlayer: NSObject, MessageFileDownloaderDelegate {
    public static let shared = VoiceMessagePlayer()
    private var audioPlayer: AudioPlayer?
    private(set) public var message: TIMMessage?
    private var downloader: MessageFileDownloader?
    public var rate: Float = 1
    public var isPlaying: Bool { return audioPlayer?.isPlaying ?? false }

    private lazy var playStatusObserver = ReplaySubject<AudioPlayStatus>.createUnbounded()
    private(set) public lazy var playStatusObservable = playStatusObserver.share().observeOn(MainScheduler()).asObservable()

    private override init() { super.init() }

    private func playAudio(_ url: URL, message: TIMMessage, atTime time: TimeInterval? = nil) {
        audioPlayer?.delegate = nil
        let isSameAudio = url.path == audioPlayer?.audioURL.path
        var finalTime = isSameAudio ? (audioPlayer?.stopTime ?? 0) : 0
        if let time = time {
            finalTime = time
        }
        Log.i("从\(finalTime)开始播放")
        let audioPlayer = AudioPlayer(audioURL: url)
        audioPlayer.delegate = self
        do {
            try audioPlayer.play(atTime: finalTime)
            self.audioPlayer = audioPlayer
            self.message = message
            playStatusObserver.onNext(.startPlaying)
        } catch (let error) {
            Log.e("音频播放出错了\(error)")
            playStatusObserver.onNext(.error(error: error))
        }
    }

    public func playVoiceMessage(_ message: TIMMessage, atTime time: TimeInterval? = nil) {
        if isPlaying, message == self.message {
            Log.i("正在播放当前音频……")
            return
        }
        if isPlaying, message != self.message {
            Log.i("需要播放新音频，停止上一个正在播放的音频")
            stopPlaying()
        }
        guard let voiceContent = message.content as? VoiceMessageContent else {
            playStatusObserver.onNext(.error(error: OSSError.invalidateObjectKey))
            return
        }
        guard let objectKey = voiceContent.objectKey else {
            playStatusObserver.onNext(.error(error: OSSError.invalidateObjectKey))
            return
        }
        let voiceUrl = URL(fileURLWithPath: objectKey, relativeTo: URL.voiceDirectory)
        if FileManager.default.fileExists(atPath: voiceUrl.path) {
            playAudio(voiceUrl, message: message, atTime: time)
            return
        }
        co_launch { [weak self] in
            let request = OSSDownloader.buildGetObjectRequest(bucketname: BucketName.voice.rawValue, objectKey: objectKey, targetFileURL: voiceUrl)
            self?.downloader?.delegate = nil
            let downloader = MessageFileDownloader(request: request, message: message)
            downloader.delegate = self
            self?.downloader = downloader
            do {
                let downloadResult = try await(promise: downloader.download())
                switch downloadResult {
                case .fulfilled(let result):
                    Log.i("文件下载成功\(result)")
                    self?.playAudio(voiceUrl, message: message, atTime: time)
                    break
                case .rejected(let error):
                    Log.e("文件下载失败\(error)")
                    self?.playStatusObserver.onNext(.error(error: error))
                    break
                }
            } catch (let error) {
                Log.e("音频文件下载失败\(error)")
                self?.playStatusObserver.onNext(.error(error: error))
            }
        }
    }


    /// 停止播放音频
    public func stopPlaying() {
        audioPlayer?.stop()
    }

    public func fileDownloader(_ downloader: MessageFileDownloader, download message: TIMMessage, progress: Int64, totalProgress: Int64) {
        playStatusObserver.onNext(.downloading(progress: progress, totalProgress: totalProgress))
        Log.i("下载进度\(progress) \(totalProgress)")
    }
}

extension VoiceMessagePlayer: AudioPlayerDelegate {
    public func audioPlayer(_ audioPlayer: AudioPlayer, playStatus status: AudioPlayStatus) {
        if case .prepare(let player) = status {
            let audioSession = AVAudioSession.sharedInstance()
            try? audioSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
            player.enableRate = true
            player.rate = rate
        }
        playStatusObserver.onNext(status)
    }
}
