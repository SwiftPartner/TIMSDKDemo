//
//  ViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import coswift
import CommonTools

class ViewController: BaseViewController, AudioRecordButtonDelegate {

    private var recorder: AudioRecorder?
    private weak var recordBtn: UIButton?
    private var audioPlayer: AudioPlayer?
    private weak var playBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "登录/测试音频录制、播放"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "聊天", style: .plain, target: self, action: #selector(joinChatRoom))

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


        let recordView = RecordAudioView()
        recordView.backgroundColor = .yellow
        view.addSubview(recordView)
        recordView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(140)
            make.top.equalTo(self.view).offset(100)
        }

        let auditionView = AuditionView()
        auditionView.backgroundColor = .red
        view.addSubview(auditionView)
        auditionView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(140)
            make.top.equalTo(recordView.snp.bottom)
        }

        let moreView = InputMoreView()
        moreView.backgroundColor = .purple
        view.addSubview(moreView)
        moreView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.height.equalTo(140)
            make.top.equalTo(auditionView.snp.bottom)
        }
    }

    @objc private func joinChatRoom() {
        showLoadingView = true
        let groupInfo = TIMCreateGroupInfo()
        groupInfo.group = "ap_10086"
        groupInfo.groupName = "10086"
        groupInfo.groupType = "Public"
        co_launch { [weak self] in
            defer { self?.showLoadingView = false }
            guard let imManager = TIMManager.sharedInstance() else { return }
            let createGroupResult = try! await(promise: imManager.createAndJoinGroup(groupInfo))
            if case .fulfilled(let result) = createGroupResult, !result.isSuccess {
                Log.e("群组创建失败………\(result)")
                return
            }
            guard let conversation = imManager.getConversation(.GROUP, receiver: "ap_10086") else {
                Log.e("会话对象获取失败")
                return
            }
            let chatController = ChatViewController(conversation: conversation)
            self?.navigationController?.pushViewController(chatController, animated: true)
        }
    }


    // MARK: 创建进入群组
    private func joinConversationFailed() {
        let alertController = UIAlertController(title: nil, message: "群组进入失败", preferredStyle: .alert)
        co_launch { [weak self] in
            if let self = self {
                let result = try! await(promise: alertController.cose_present(from: self, cancelTitle: "取消", confirmTitle: "再试一次"))
                if case .fulfilled(let title) = result, title == "取消" {
                    return
                }
                self.joinChatRoom()
            }
        }
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
        } catch(let error) {
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
        co_launch {
            let result = try await(promise: OSSManager.shared.fetchBucket(name: "windbird-voice"))
            switch result {
            case .fulfilled(let result):
                Log.i("bucket获取成功\(result)")
            case .rejected(let error):
                Log.e("bucket获取失败\(error)")
            }
        }
    }
}

