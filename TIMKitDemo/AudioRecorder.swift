//
//  Recorder.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation
import CommonTools

public class AudioRecorder: NSObject {
    
    private var voiceDirectory: URL
    private var maxDuration: Int
    private(set) public var recorder: AVAudioRecorder?
    private(set) public var voiceURL: URL?
    private var timer: Timer?
    public var onPowerChanged: ((Int)->Void)?
    /// 录制时间变化回调（总时间，剩余时间）-> Void
    public var onRecordTimeChanged: ((Int, Int) -> Void)?
    public var isRecording = false
    private var isInterrupted = false
    
    public var duration: Int? {
        if !isRecording, let voiceURL = voiceURL {
            let asset = AVURLAsset(url: voiceURL)
            let duration = Int(ceil(CMTimeGetSeconds(asset.duration) - 0.1))
            return duration;
        }
        return nil
    }
    
    init(voiceDirectory: URL, maxDuration: Int = 180) {
        self.maxDuration = maxDuration
        if voiceDirectory.path.hasSuffix("/") {
            self.voiceDirectory = voiceDirectory
        } else {
            self.voiceDirectory = voiceDirectory
        }
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(audioRecorderBeginInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    // MARK: 处理音频录制中途被打断事件处理
    @objc private func audioRecorderBeginInterruption(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else  {
                return
        }
        if type == .began {
            isInterrupted = true
            Log.i("停止录制……")
            pause()
        }
        if type == .ended, let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            isInterrupted = false
            if options.contains(.shouldResume) {
                Log.i("恢复录制……")
                recorder?.record()
            } else {
                Log.i("停止录制……")
                stop()
            }
        }
    }
    
    // MARK: 播放音频
    func record() throws {
        let audioSession = AVAudioSession.sharedInstance();
        try audioSession.setCategory(.playAndRecord)
        let options = AVAudioSession.SetActiveOptions()
        try audioSession.setActive(true, options: options)
        let voiceName = THelper.genVoiceName(nil, withExtension: "wav")
        if !FileManager.default.fileExists(atPath: self.voiceDirectory.path) {
            try FileManager.default.createDirectory(at: voiceDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        let voiceURL = voiceDirectory.appendingPathComponent(voiceName!)
        self.voiceURL = voiceURL
        Log.i("录制的音频路径为: \(voiceURL.path)")
        let settings = [AVSampleRateKey: NSNumber(value: Float(8000)),
                        AVFormatIDKey: NSNumber(value: Int(kAudioFormatLinearPCM)),
                        AVLinearPCMBitDepthKey: NSNumber(value: Int(16)),
                        AVNumberOfChannelsKey: NSNumber(value: Int(1)),
                        AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.high.rawValue)]
        let audioRecorder = try AVAudioRecorder(url: voiceURL, settings: settings)
        audioRecorder.isMeteringEnabled = true
        let prepared = audioRecorder.prepareToRecord()
        let recordSuccess = audioRecorder.record()
        if prepared, recordSuccess {
            self.recorder = audioRecorder
            recorder?.updateMeters()
            let timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(recordTick(timer:)), userInfo: nil, repeats: true)
            self.timer = timer
            isRecording = true
            return
        }
        stop()
        throw RecorderError.failed
    }
    
    // MARK: 暂停录制
    func pause() {
        if let recorder = recorder, recorder.isRecording {
            recorder.pause()
        }
    }
    
    // MARK: 停止录制
    func stop() {
        timer?.invalidate()
        timer = nil
        if let recorder = recorder, recorder.isRecording {
            recorder.stop()
        }
        recorder = nil
        isRecording = false
    }
    
    // MARK: 处理录制时间
    @objc private func recordTick(timer: Timer) {
        if isInterrupted {
            Log.i("录制被打断……")
            return
        }
        if let recorder = recorder {
            recorder.updateMeters()
            let power = recorder.averagePower(forChannel: 0)
            onPowerChanged?(Int(power))
            let currentTime = recorder.currentTime
            let time = Int(ceil(currentTime - 0.1))
            if time >= maxDuration {
                stop()
            }
            onRecordTimeChanged?(self.maxDuration, time)
            Log.i("已经录制了\(currentTime)秒  -> \(time)")
        }
    }
}
