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

public protocol VoiceMessagePlayerListener: NSObject {
    func onPlayingVoiceMessageStatusChanged(_ status: VoiceMessagePlayStatus, message: TIMMessage)
}

public enum VoiceMessagePlayStatus {
    case startPlaying
    case downloading(progress: Int64, totalProgress: Int64)
    case stop
    case error(error: Error)
    case playProgress(current: Int, duration: Int)
}

public class VoiceMessagePlayer: NSObject, MessageFileDownloaderDelegate {
    public static let shared = VoiceMessagePlayer()
    private var audioPlayer: AudioPlayer?
    private lazy var listeners = Array<VoiceMessagePlayerListener>()
    private(set) public var message: TIMMessage?
    private var downloader: MessageFileDownloader?
    public var isPlaying: Bool {
        return audioPlayer?.isPlaying ?? false
    }

    private override init() { super.init() }

    private func playAudio(_ url: URL, message: TIMMessage) {
        audioPlayer?.delegate = nil
        audioPlayer?.onTimeChanged = nil
        let audioPlayer = VoiceMessageAudioPlayer(audioURL: url, message: message)
        do {
            try audioPlayer.play()
            self.audioPlayer = audioPlayer
            self.message = message
            notifyStaus(.startPlaying, message: message)
            audioPlayer.messageAudioDelegate = self
            audioPlayer.onTimeChanged = { [weak self] duration, now in
                self?.notifyStaus(.playProgress(current: now, duration: duration), message: message)
            }
        } catch (let error) {
            Log.e("音频播放出错了\(error)")
            notifyStaus(.error(error: error), message: message)
        }
    }

    public func playVoiceMessage(_ message: TIMMessage) {
        if isPlaying, message.msgId() == self.message?.msgId() {
            return
        }
        if isPlaying, message.msgId() != self.message?.msgId() {
            stopPlaying()
        }
        guard let voiceContent = message.content as? VoiceMessageContent else {
            notifyStaus(.error(error: OSSError.invalidateObjectKey), message: message)
            return
        }
        guard let objectKey = voiceContent.objectKey else {
            notifyStaus(.error(error: OSSError.invalidateObjectKey), message: message)
            return
        }
        let voiceUrl = URL(fileURLWithPath: objectKey, relativeTo: URL.voiceDirectory)
        if FileManager.default.fileExists(atPath: voiceUrl.path) {
            playAudio(voiceUrl, message: message)
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
                    self?.playAudio(voiceUrl, message: message)
                    break
                case .rejected(let error):
                    Log.e("文件下载失败\(error)")
                    self?.notifyStaus(.error(error: error), message: message)
                    break
                }
            } catch (let error) {
                Log.e("音频文件下载失败\(error)")
                self?.notifyStaus(.error(error: error), message: message)
            }
        }
    }


    /// 停止播放音频
    public func stopPlaying() {
        audioPlayer?.stop()
        guard let message = message else {
            return
        }
        notifyStaus(.stop, message: message)
    }


    // MARK: 广播音频状态
    private func notifyStaus(_ status: VoiceMessagePlayStatus, message: TIMMessage) {
        listeners.forEach { listener in
            listener.onPlayingVoiceMessageStatusChanged(status, message: message)
        }
    }

    public func fileDownloader(_ downloader: MessageFileDownloader, download message: TIMMessage, progress: Int64, totalProgress: Int64) {
        notifyStaus(.downloading(progress: progress, totalProgress: totalProgress), message: message)
        Log.i("下载进度\(progress) \(totalProgress)")
    }


    /// 添加音频播放状态监听器
    /// - Parameter listener: VoiceMessagePlayerListener
    public func addListener(_ listener: VoiceMessagePlayerListener) {
        let contains = listeners.contains(where: { temp -> Bool in
            return temp == listener
        })
        if !contains {
            listeners.append(listener)
        }
    }

    //   MARK: 移除所有监听器
    ///  移除音频播放状态监听器
    public func removeListener(_ listener: VoiceMessagePlayerListener) {
        let index = listeners.firstIndex { temp -> Bool in
            temp == listener
        }
        if let index = index {
            listeners.remove(at: index)
        }
    }

    //   MARK: 移除所有监听器
    ///  移除所有的
    public func clearListeners() {
        listeners.removeAll()
    }
}

extension VoiceMessagePlayer: VoiceMessageAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, message: TIMMessage, successfully flag: Bool) {
        notifyStaus(.stop, message: message)
    }
}
