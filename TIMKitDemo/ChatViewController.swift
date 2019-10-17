//
//  ChatViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SnapKit
import coswift
import AVFoundation

public class ChatViewController: BaseViewController {
    
    private weak var messageController: MessageViewController!
    private weak var messageInputView: MessageInputView!
    private var conversation: TIMConversation!
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = .groupTableViewBackground
        }
        addMessageInputView()
        addMessagesView()
        co_launch { [weak self] in
            if let self = self {
                let groupInfo = TIMCreateGroupInfo()
                groupInfo.groupType = "Public"
                groupInfo.group = "ap_10086"
                groupInfo.groupName = "10086"
                let resolution = try! await(promise: TIMManager.sharedInstance()!.createGroup(groupInfo: groupInfo))
                if case .fulfilled(let result) = resolution {
                    Log.i("进入群组结果：", result)
                    if result.isSuccess {
                        self.loadMessage()
                    }
                }
            }
        }
    }
    
    private func loadMessage() {
        let conversation = TIMManager.sharedInstance()?.getConversation(.GROUP, receiver: "ap_10086")
        self.conversation = conversation
        let lastMsg = conversation?.getLastMsg()
        conversation?.getMessage(10, last: lastMsg, succ: {[weak self] msgs in
            if let self = self, let msgs = msgs as? [TIMMessage] {
                self.messageController.appendMessages(msgs)
            }
            Log.i("获取到了会话列表……")
            }, fail: { (code, desc) in
                Log.i("会话列表获取失败\(code) \(desc ?? "")")
        })
    }
    
    // MARK: 文本消息输入完成，发送文本消息
    private func sendTextMsg(text: String) {
        if text.trimmingCharacters(in: [" ", "\n", "\t"]).count == 0 {
            Log.i("输入的内容为空，不发送消息")
            return
        }
        let message = TIMMessage()
        let textElem = TIMTextElem()
        textElem.text = text
        message.add(textElem)
        co_launch { [weak self] in
            if let conversation  = self?.conversation {
                let resolution = try! await(promise: conversation.sendMessage(message))
                if case .fulfilled(let result) = resolution {
                    if result.isSuccess {
                        self?.messageController.didSendMessage(message)
                        Log.i("消息发送成功……")
                    } else {
                        Log.e("消息发送失败\(result)")
                    }
                }
            }
        }
        self.conversation.send(message, succ: {
            Log.i("文本消息发送成功……")
        }) { (code, desc) in
            Log.i("文本消息发送失败 \(code)  \(desc ?? "")")
        }
    }
    
    private func sendVoiceMessage() {
        let message = TIMMessage()
        let voiceElem = TIMSoundElem()
        //        voiceElem.second =
        //        message.add(<#T##elem: TIMElem!##TIMElem!#>)
    }
    
    private func sendImageMsg() {
        let imageElem = TIMImageElem()
        imageElem.path = ""
        let message = TIMMessage()
        message.add(imageElem)
        conversation.send(message, succ: {
            Log.i("图片消息发送成功……")
        }) { (code, desc) in
            Log.i("图片消息发送失败\(code) \(desc ?? "")")
        }
    }
    
    private func addMessageInputView() {
        let inputView = MessageInputView()
        inputView.recordButtonDelegate = self
        inputView.auditionViewDelegate = self
        self.messageInputView = inputView
        inputView.backgroundColor = .groupColor
        inputView.delegate = self
        view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    private func addMessagesView() {
        let messageController = MessageViewController()
        messageController.delegate = self
        self.messageController = messageController
        addChild(messageController)
        view.addSubview(messageController.view)
        messageController.view.setContentCompressionResistancePriority(.required, for: .vertical)
        messageController.view.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(messageInputView.snp.top)
        }
        messageController.didMove(toParent: self)
    }
    
    deinit {
        Log.w("页面关闭了……")
    }
}

extension ChatViewController: MessageViewControllerDelegate {
    public func tableViewWillBeginDragging(_ tableView: UITableView) {
        messageInputView.showInputBarOnly()
    }
}

extension ChatViewController: AuditionViewDelegate, AudioRecordButtonDelegate, AVAudioPlayerDelegate{
    
    public func onStartRecord(recordButton: AudioRecordButton) {
        Log.i("开始录制音频……")
        let audioRecorder = AudioRecorder(voiceDirectory: .voiceDirectory, maxDuration: 180)
        do {
            try audioRecorder.record()
            audioRecorder.onRecordTimeChanged = {[weak self] max, current in
                Log.i("已经录制了\(current)秒，总共\(max)秒")
                if current == max {
                    self?.messageInputView.recordButton.stopRecord()
                    self?.messageInputView.showAuditionView = true
                }
            }
            self.audioRecorder = audioRecorder
        } catch(let error) {
            Log.e("音频录制失败\(error)")
        }
    }
    
    public func onStopRecord(recordButton: AudioRecordButton) {
        Log.i("停止录制音频……")
        if let audioRecorder = self.audioRecorder {
            audioRecorder.stop()
            messageInputView.showAuditionView = true
        }
    }
    
    public func onClickPlayBtn(_ sender: UIButton, of auditionView: AuditionView) {
        if !sender.isSelected, let voiceUrl = audioRecorder?.voiceURL {
            let audioPlayer = AudioPlayer(audioURL: voiceUrl)
            audioPlayer.delegate = self
            do {
                try audioPlayer.play()
            } catch(let error) {
                Log.e("音频播放失败\(error)")
            }
        }
        if sender.isSelected, let audioPlayer = audioPlayer {
            audioPlayer.stop()
        }
        sender.isSelected = !sender.isSelected
    }
    
    public func onClickSendBtn(_ sender: UIButton, of auditionView: AuditionView) {
        messageInputView.showAuditionView = false
    }
    
    public func onClickDeleteBtn(_ sender: UIButton, of auditionView: AuditionView) {
        messageInputView.showAuditionView = false
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Log.i("音频试听自动播放完毕……")
        messageInputView.auditionView.isPlaying = false
    }
}

extension ChatViewController: MessageInputViewDelegate {
    public func messageInputView(_ inutView: MessageInputView, didEndEditing text: String) {
        sendTextMsg(text: text)
    }
}
