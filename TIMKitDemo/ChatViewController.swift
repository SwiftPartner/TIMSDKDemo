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
import CommonTools
import COSwiftExtension

public class ChatViewController: BaseViewController {

    private weak var coursewareView: CoursewareView!
    private weak var messageController: MessageViewController!
    private weak var messageInputView: MessageInputView!
    private var conversation: TIMConversation
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    private var auditionVoiceUrl: URL?
    private var sendingMessage: TIMMessage?

    public init(conversation: TIMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .groupColor
        addCoursewareView()
        addMessageInputView()
        addMessagesView()
        coursewareView.makeShadow()
        view.bringSubviewToFront(coursewareView)
        
        
        
        let audioRateView = AudioRateView()
        audioRateView.delegate = self
        audioRateView.backgroundColor = .white
        audioRateView.makeCorner(radius: 22)
        view.addSubview(audioRateView)
        audioRateView.snp.makeConstraints { make in
            make.right.centerY.equalTo(view)
        }
    }

    public func sendMessage(msgContent: MessageContent) {
        msgContent.pptPage = NSNumber(value: coursewareView.currentPage)
        msgContent.pptTotalPage = NSNumber(value: coursewareView.totalPage)
        let message = TIMMessage.message(content: msgContent)
        messageController.tableView.contentInset = .zero
        messageController.scrollToBottom()
        messageController.didSendMessage(message)
    }

    // MARK: 文本消息输入完成，发送文本消息
    private func sendTextMsg(text: String) {
        if text.trimmingCharacters(in: [" ", "\n", "\t"]).count == 0 {
            Log.i("输入的内容为空，不发送消息")
            return
        }
        let textContent = TextMessageContent(text: text)
        sendMessage(msgContent: textContent)
    }

    // MARK: 发送语音消息
    private func sendVoiceMessage(withFile url: URL) {
        if let messageContent = VoiceMessageContent.messageContent(voiceLoalUrl: url) {
            sendMessage(msgContent: messageContent)
            return
        }
        Log.e("语音消息发送失败")
    }

    // MARK: 发送图片消息
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

    // MARK: UI搭建 - 课件视图
    private func addCoursewareView() {
        let frame = CGRect(x: 0, y: 0, width: view.width, height: view.width * 0.75)
        let coursewareView = CoursewareView(frame: frame)
        coursewareView.collectionView?.backgroundColor = .white
        self.coursewareView = coursewareView
        view.addSubview(coursewareView)
        coursewareView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.height.equalTo(coursewareView.snp.width).multipliedBy(0.75)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    // MARK:  UI搭建 - 消息输入视图
    private func addMessageInputView() {
        let inputView = MessageInputView()
        inputView.recordButtonDelegate = self
        inputView.auditionViewDelegate = self
        self.messageInputView = inputView
        //        inputView.backgroundColor = .groupColor
        inputView.delegate = self
        view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    // MARK: UI搭建 - 消息列表视图
    private func addMessagesView() {
        let conversation = TIMManager.sharedInstance()!.getConversation(.GROUP, receiver: "ap_10086")
        let messageController = MessageViewController(conversation: conversation!)
        messageController.delegate = self
        self.messageController = messageController
        addChild(messageController)
        view.addSubview(messageController.view)
        messageInputView.setContentCompressionResistancePriority(.required, for: .vertical)
        messageController.view.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(coursewareView.snp.bottom)
            make.bottom.equalTo(messageInputView.snp.top)
        }
        messageController.didMove(toParent: self)
    }

    deinit {
        Log.w("页面关闭了……")
    }
}

// MARK: 消息列表控制器回调
extension ChatViewController: MessageViewControllerDelegate {
    public func tableViewWillBeginDragging(_ tableView: UITableView) {
        view.endEditing(true)
        messageInputView.showInputBarOnly()
    }

    public func didSelectMessage(_ message: TIMMessage) {
        guard let page = message.content?.pptPage?.intValue else {
            Log.i("当前消息未关联课件")
            return
        }
        Log.i("滚动到课件的第\(page)页")
        coursewareView.scrollTo(page: page)
    }
}

// MARK: 音频试听回调、录音按钮点击事件回调、音频播放回调
extension ChatViewController: AuditionViewDelegate, AudioRecordButtonDelegate, VoiceMessagePlayerListener {

    public func onStartRecord(recordButton: AudioRecordButton) {
        Log.i("开始录制音频……")
        VoiceMessagePlayer.shared.stopPlaying()
        let audioRecorder = AudioRecorder(voiceDirectory: .voiceDirectory, maxDuration: 180)
        do {
            try audioRecorder.record()
            audioRecorder.onRecordTimeChanged = { [weak self] max, current in
                Log.i("已经录制了\(current)秒，总共\(max)秒")
                self?.messageInputView.timeLabel.text = "\(current)/\(max)s"
                self?.messageInputView.timeLabel.isHidden = false
                if current == max {
                    self?.messageInputView.timeLabel.isHidden = true
                    self?.messageInputView.recordButton.stopRecord()
                    self?.messageInputView.showAuditionView = true
                    let duration = self?.audioRecorder?.duration ?? 0
                    self?.messageInputView.timeLabel.text = "\(duration)/\(max)s"
                }
            }
            self.audioRecorder = audioRecorder
        } catch(let error) {
            Log.e("音频录制失败\(error)")
        }
    }
    // MARK: 停止播放音频
    public func onStopRecord(recordButton: AudioRecordButton) {
        Log.i("停止录制音频……")
        if let audioRecorder = self.audioRecorder {
            audioRecorder.stop()
            let duration = audioRecorder.duration ?? 0
            messageInputView.timeLabel.text = "\(duration)/\(180)s"
            messageInputView.showAuditionView = true
        }
    }
    // MARK: 播放音频（试听）
    public func onClickPlayBtn(_ sender: UIButton, of auditionView: AuditionView) {
        guard let voiceUrl = audioRecorder?.voiceURL, let voiceContent = VoiceMessageContent.messageContent(voiceLoalUrl: voiceUrl) else {
            Log.e("无效的音频文件")
            return
        }
        let voicePlayer = VoiceMessagePlayer.shared
        voicePlayer.addListener(self)
        if (auditionVoiceUrl != voiceUrl && voicePlayer.isPlaying) || voicePlayer.message != sendingMessage {
            voicePlayer.stopPlaying()
        }
        if auditionVoiceUrl == nil || auditionVoiceUrl != voiceUrl {
            let message = TIMMessage.message(content: voiceContent)
            sendingMessage = message
        }
        if voicePlayer.isPlaying {
            Log.i("停止播放试听音频……")
            voicePlayer.stopPlaying()
        } else {
            Log.i("开始播放试听音频……")
            voicePlayer.playVoiceMessage(sendingMessage!)
        }
    }
    // MARK: 发送音频
    public func onClickSendBtn(_ sender: UIButton, of auditionView: AuditionView) {
        stopPlayAudio()
        messageInputView.timeLabel.isHidden = true
        messageInputView.timeLabel.text = "0/180s"
        messageInputView.showAuditionView = false
        if let voiceURL = audioRecorder?.voiceURL {
            DispatchQueue.main.async {
                self.sendVoiceMessage(withFile: voiceURL)
            }
        }
    }

    // MARK: 删除音频
    public func onClickDeleteBtn(_ sender: UIButton, of auditionView: AuditionView) {
        stopPlayAudio()
        messageInputView.showAuditionView = false
        messageInputView.timeLabel.isHidden = true
        messageInputView.timeLabel.text = "0/\(180)s"
        if let voiceURL = audioRecorder?.voiceURL {
            do {
                try FileManager.default.removeItem(at: voiceURL)
            } catch(let error) {
                Log.e("音频删除失败\(error)")
            }
        }
    }

    public func onPlayingVoiceMessageStatusChanged(_ status: VoiceMessagePlayStatus, message: TIMMessage) {
        if message != self.sendingMessage {
            Log.i("不是试听音频事件，不处理")
            return
        }
        switch status {
        case .startPlaying:
            auditionVoiceUrl = audioRecorder?.voiceURL
            Log.i("开始播放试听音频")
            messageInputView.auditionView.isPlaying = true
        case .downloading(let progress, let totalProgress):
            Log.i("试听音频下载进度\(progress) \(totalProgress)")
        case .stop:
            Log.i("试听音频播放结束")
            messageInputView.auditionView.isPlaying = false
        case .error(let error):
            Log.e("试听音频播放失败\(error)")
            messageInputView.auditionView.playButton.isSelected = false
        case .playProgress(let current, let duration):
            break
//            Log.i("试听音频播放进度\(current)  \(duration)")

        }
    }

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Log.i("音频试听自动播放完毕……")
        messageInputView.auditionView.isPlaying = false
        messageInputView.auditionView.playButton.isSelected = false
    }

    private func stopPlayAudio() {
        VoiceMessagePlayer.shared.stopPlaying()
    }
}

// MARK: 消息输入视图回调
extension ChatViewController: MessageInputViewDelegate {
    public func messageInputView(_ inputView: MessageInputView, didEndEditing text: String) {
        sendTextMsg(text: text)
        inputView.resetText("")
    }

    public func messageInputView(_ inputView: MessageInputView, didHeightChanged height: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.messageController.scrollToBottom(animated: true)
        }
        Log.i("高度变化\(height)")
    }
}

extension ChatViewController: AudioRateViewDelegate {
    
    public func audioRateView(_ rateView: AudioRateView, didSelectRate rate: Double) {
        
    }
}
