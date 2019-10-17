//
//  ViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AudioRecordButtonDelegate {
    
    private var recorder: AudioRecorder?
    private weak var recordBtn: UIButton?
    private var audioPlayer: AudioPlayer?
    private weak var playBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录/测试音频录制、播放"
        let param = TIMLoginParam()
        let userId = "kakaxi"
        param.identifier = userId
        param.userSig = GenerateTestUserSig.genTestUserSig(userId)
        TIMManager.sharedInstance()?.login(param, succ: { [weak self] in
            Log.i("登录成功……")
            self?.addRecordButton()
            self?.addPlaybackBtn()
            self?.changeRateBtn()
            }, fail: { (code, msg) in
                Log.e("登录失败……\(code) \(msg ?? "")")
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "聊天", style: .plain, target: self, action: #selector(joinChatRoom))
        // Do any additional setup after loading the view.
    }
    
    @objc private func joinChatRoom() {
        let chatController = ChatViewController()
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    
    func addRecordButton() {
        let recordButton = AudioRecordButton()
        recordBtn = recordButton
        recordButton.setup(recordMode: .touchToRecord)
        view.addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        recordButton.delegate = self
    }
    
    func onStartRecord(recordButton: AudioRecordButton) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let voiceDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("voice")
        let recorder = AudioRecorder(voiceDirectory: voiceDir)
        do {
            try recorder.record()
            self.recorder = recorder
        } catch(let error)  {
            Log.e("因为录制失败\(error)")
        }
    }
    
    func onStopRecord(recordButton: AudioRecordButton) {
        if let isRecording = recorder?.isRecording, isRecording {
            recorder?.stop()
            return
        }
    }
    
    func addPlaybackBtn() {
        let playBtn = UIButton()
        self.playBtn = playBtn
        playBtn.setTitleColor(.red, for: .normal)
        playBtn.setTitle("播放", for: .normal)
        view.addSubview(playBtn)
        playBtn.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            if let recordBtn = recordBtn {
                make.top.equalTo(recordBtn.snp.bottom)
            }
        }
        playBtn.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
    }
    
    func changeRateBtn() {
        let changeRateBtn = UIButton()
        changeRateBtn.setTitle("改变播放速率", for: .normal)
        changeRateBtn.setTitleColor(.red, for: .normal)
        view.addSubview(changeRateBtn)
        changeRateBtn.snp.makeConstraints { make in
            if let playBtn = playBtn {
                make.left.equalTo(playBtn.snp.right).offset(20)
                make.centerY.equalTo(playBtn)
            }
        }
        changeRateBtn.addTarget(self, action: #selector(changeRate), for: .touchUpInside)
    }
    
    @objc func changeRate() {
        var currentTime = 0.0
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            currentTime = audioPlayer.player!.currentTime
            audioPlayer.stop()
        }
        playAudioWithRate(Float.random(in: 0.1...2), currentTime: currentTime)
    }
    
    
    @objc func playAudio() {
        playAudioWithRate(1)
    }
    
    @objc func playAudioWithRate(_ rate: Float, currentTime: TimeInterval = 0.0) {
        guard let audioURL = recorder?.voiceURL else {
            return
        }
        if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
            audioPlayer.stop()
            return
        }
        let audioPlayer = AudioPlayer(audioURL: audioURL)
        self.audioPlayer = audioPlayer
        audioPlayer.preparePlayer = { player in
            player.enableRate = true
            player.rate = rate
            player.currentTime = currentTime
        }
        do {
            try audioPlayer.play()
        } catch (let error) {
            Log.i("音频播放失败\(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let controller = MemoryTestViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

