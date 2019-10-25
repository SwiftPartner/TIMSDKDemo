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
import RxSwift
import MobileCoreServices
import Darwin

public class ChatViewController: BaseViewController {

    private weak var coursewareView: CoursewareView!
    private weak var messageController: MessageViewController!
    private weak var messageInputView: MessageInputView!
    private var inputViewHeightConstraint: Constraint!
    private var conversation: TIMConversation
    private var audioRecorder: AudioRecorder?
    private var audioPlayer: AudioPlayer?
    private var auditionVoiceUrl: URL?
    private var sendingMessage: TIMMessage!
    private lazy var disposeBag = DisposeBag()


    public init(conversation: TIMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    public override var prefersStatusBarHidden: Bool {
//        return navigationController?.isNavigationBarHidden == true
//    }
//
//    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
//        return .none
//    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "聊天室"
        navigationController?.hidesBarsOnSwipe = true
        view.backgroundColor = .groupColor
        addCoursewareView()
        addMessageInputView()
        addMessagesView()
        coursewareView.makeShadow()
        view.bringSubviewToFront(coursewareView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.navigationController?.setNavigationBarHidden(true, animated: false)
        }

        let audioRateView = AudioRateView()
        audioRateView.delegate = self
        audioRateView.backgroundColor = .white
        audioRateView.makeCorner(radius: 22)
        view.addSubview(audioRateView)
        audioRateView.snp.makeConstraints { make in
            make.right.centerY.equalTo(view)
        }
        listenAudioPlayStatus()
    }

    private func listenAudioPlayStatus() {
        let voicePlayer = VoiceMessagePlayer.shared
        voicePlayer.playStatusObservable.subscribe(onNext: { [weak self] status in
            let message = voicePlayer.message
            if message != self?.sendingMessage {
                Log.i("不是试听音频事件，不处理")
                return
            }
            switch status {
            case .startPlaying:
                self?.auditionVoiceUrl = self?.audioRecorder?.voiceURL
                Log.i("开始播放试听音频")
                self?.messageInputView.isPlayingAudition = true
            case .downloading(let progress, let totalProgress):
                Log.i("试听音频下载进度\(progress) \(totalProgress)")
            case .stop:
                Log.i("试听音频播放结束")
                self?.messageInputView.isPlayingAudition = false
            case .error(let error):
                Log.e("试听音频播放失败\(error)")
                self?.messageInputView.isPlayingAudition = false
            case .playProgress(let current, let duration):
                //            Log.i("试听音频播放进度\(current)  \(duration)")
                break
            case .prepare(let player):
                Log.i("...")
            }
        }).disposed(by: disposeBag)
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
    private func sendImageMsg(image: UIImage) {
        let imageName = THelper.genImageName(nil)
        
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

    // MARK: 发送音频消息
    private func sendVideoMsg(url: URL) {

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
            make.height.equalTo(coursewareView.snp.width).multipliedBy(9.0 / 16.0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }

    // MARK:  UI搭建 - 消息输入视图
    private func addMessageInputView() {
        let inputView = MessageInputView()
        inputView.recordView.delegate = self
        inputView.moreView.delegate = self
        self.messageInputView = inputView
        inputView.delegate = self
        view.addSubview(inputView)
        let height = messageInputView.inputBarHeight
        inputView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            self.inputViewHeightConstraint = make.height.equalTo(height).constraint
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
        VoiceMessagePlayer.shared.stopPlaying()
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
extension ChatViewController: AudioRecordViewDelegate {
    public func onStartRecord(from recordView: AudioRecordView) {
        Log.i("开始录制音频……")
        stopPlayAudio()
        let audioRecorder = AudioRecorder(voiceDirectory: .voiceDirectory, maxDuration: 180)
        audioRecorder.onRecordTimeChanged = { [weak self] max, current in
            Log.i("已经录制了\(current)秒，总共\(max)秒")
            self?.messageInputView.updateTime("\(current)/\(max)s")
            self?.messageInputView.hideTimeLabel(false)
            if current == max {
                self?.messageInputView.hideTimeLabel(true)
                self?.messageInputView.stopRecord()
                let duration = self?.audioRecorder?.duration ?? 0
                self?.messageInputView.updateTime("\(duration)/\(max)s")
            }
        }
        do {
            try audioRecorder.record()
            self.audioRecorder = audioRecorder
        } catch(let error) {
            Log.e("音频录制失败\(error)")
        }
    }

    // MARK: 停止录制音频
    public func onStopRecord(from recordView: AudioRecordView) {
        if let audioRecorder = self.audioRecorder {
            Log.i("停止录制音频……")
            audioRecorder.stop()
            let duration = audioRecorder.duration ?? 0
            messageInputView.updateTime("\(duration)/\(duration)s")
        }
    }

    public func onPlayAudition(from recordView: AudioRecordView) {
        guard let voiceUrl = audioRecorder?.voiceURL, let voiceContent = VoiceMessageContent.messageContent(voiceLoalUrl: voiceUrl) else {
            Log.e("无效的音频文件")
            return
        }
        let voicePlayer = VoiceMessagePlayer.shared
        if (auditionVoiceUrl != voiceUrl && voicePlayer.isPlaying) || voicePlayer.message != sendingMessage {
            stopPlayAudio()
        }
        if auditionVoiceUrl == nil || auditionVoiceUrl != voiceUrl {
            let message = TIMMessage.message(content: voiceContent)
            sendingMessage = message
        }
        if voicePlayer.isPlaying {
            Log.i("停止播放试听音频……")
            stopPlayAudio()
        } else {
            Log.i("开始播放试听音频……")
            startPlayAudio(message: sendingMessage!)
        }
    }

    public func onDelete(from recordView: AudioRecordView) {
        stopPlayAudio()
        messageInputView.hideTimeLabel(true)
        messageInputView.updateTime("0/\(180)s")
        if let voiceURL = audioRecorder?.voiceURL {
            do {
                try FileManager.default.removeItem(at: voiceURL)
            } catch(let error) {
                Log.e("音频删除失败\(error)")
            }
        }
    }

    // MARK: 发送音频
    public func onSend(from recordView: AudioRecordView) {
        stopPlayAudio()
        messageInputView.hideTimeLabel(true)
        messageInputView.updateTime("0/180s")
        if let voiceURL = audioRecorder?.voiceURL {
            DispatchQueue.main.async {
                self.sendVoiceMessage(withFile: voiceURL)
            }
        }
    }

    // MARK: 停止播放试听音频
    private func stopPlayAudio() {
        messageController.autoPlay = false
        VoiceMessagePlayer.shared.stopPlaying()
    }

    private func startPlayAudio(message: TIMMessage) {
        VoiceMessagePlayer.shared.playVoiceMessage(message)
        messageController.autoPlay = true
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
        inputViewHeightConstraint.update(offset: height)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        Log.i("高度变化\(height)")
    }
}

// MARK: 更多按钮点击回调
extension ChatViewController: InputMoreViewDelegate {
    public func moreView(_ moreView: InputMoreView, didSelectMenu menu: MoreMenu) {
        switch menu.type {
        case .image:
            Log.i("准备发送图片消息")
            pickMediaFromPicker(type: menu.type)
        case .video:
            Log.i("准备发送视频消息")
            pickMediaFromPicker(type: menu.type)
        case .courseware:
            Log.i("准备发送课件")
        }
    }

    private func pickMediaFromPicker(type: MoreMenuType) {
        let sourceType = type == .image ? kUTTypeImage : kUTTypeMovie
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [sourceType as String]
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        present(picker, animated: true, completion: nil)
    }
}

// MARK: 修改音频倍速回调
extension ChatViewController: AudioRateViewDelegate {
    public func audioRateView(_ rateView: AudioRateView, didSelectRate rate: Float) {
        VoiceMessagePlayer.shared.rate = rate
        if VoiceMessagePlayer.shared.isPlaying, let message = VoiceMessagePlayer.shared.message {
            stopPlayAudio()
            startPlayAudio(message: message)
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [
        UIImagePickerController.InfoKey: Any]) {
        picker.delegate = nil
        picker.dismiss(animated: true) {
            let mediaType = info[.mediaType] as! String
            if mediaType == kUTTypeImage as String {
                var image = info[.originalImage] as! UIImage
                if image.imageOrientation != .up {
                    let aspectRatio = min(1920 / image.width, 1920 / image.height)
                    let aspectWidth = image.width * aspectRatio
                    let aspectHeight = image.height * aspectRatio
                    UIGraphicsBeginImageContext(CGSize(width: aspectWidth, height: aspectHeight))
                    image.draw(in: CGRect(x: 0, y: 0, width: aspectWidth, height: aspectHeight))
                    image = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                }
                self.sendImageMsg(image: image)
            } else {
                let videoUrl = info[.mediaURL] as! URL
                self.sendVideoMsg(url: videoUrl)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        picker.delegate = nil
    }
}
