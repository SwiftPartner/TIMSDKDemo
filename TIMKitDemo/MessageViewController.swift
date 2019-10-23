//
//  MessageViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import CommonTools
import coswift
import MJRefresh

@objc public protocol MessageViewControllerDelegate {
    @objc optional func tableViewWillBeginDragging(_ tableView: UITableView)
    @objc optional func didSelectMessage(_ message: TIMMessage)
}

public class MessageViewController: BaseViewController {

    public private(set) weak var tableView: UITableView!

    private let cellID = "cell_ID"
    private let textCellID = "text_cell"
    private let imageCellID = "image_cell"
    private let voiceCellID = "voice_cell"
    private let videoCellID = "video_cell"
    public var conversation: TIMConversation
    private lazy var viewModel = MessagesViewModel(conversation: conversation)

    private(set) public lazy var messages: Array<TIMMessage> = []
    public weak var delegate: MessageViewControllerDelegate?
    private var audioPlayer: AudioPlayer?
    private var autoPlay: Bool = true

    public init(conversation: TIMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadMessages()
    }

    @objc private func onRefresh() {
        Log.i("开始刷新了……")
//        loadMessages(pulldown: true)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
//            self.tableView.refreshControl?.endRefreshing()
//        })
    }

    // MARK: 创建TableView
    private func setupTableView() {
        let tableView = UITableView()
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadMessages(pulldown: true)
        })
        self.tableView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 130
        tableView.backgroundColor = .groupColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TextMessageCell.self, forCellReuseIdentifier: textCellID)
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellID)
        tableView.register(VoiceMessageCell.self, forCellReuseIdentifier: voiceCellID)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    // MARK: 第一加载消息，或者收到新消息，添加动画效果
    private func loadMessages(pulldown: Bool = false) {
        co_launch { [weak self] in
            defer { self?.tableView.refreshControl?.endRefreshing() }
            guard let self = self else {
                return
            }
            let loadMessageResult = try! await(promise: self.viewModel.loadMessages())
            if case .fulfilled(let messageResult) = loadMessageResult, !messageResult.isSuccess {
                Log.e("消息拉取失败\(messageResult)")
                return
            }
            let newMessages = self.viewModel.messages
            self.tableView.mj_header.isHidden = !self.viewModel.hasMoreMessages
            if pulldown {
                self.insertMessages(newMessages)
                return
            }
            Log.i("消息拉取成功")
            self.appendMessages(newMessages)
            if let firstMsg = self.viewModel.messages.first {
                self.autoPlayFromMessage(msg: firstMsg)
            }
        }
    }

    /// 消息发送成功
    /// - Parameter message: 消息
    public func didSendMessage(_ message: TIMMessage) {
        message.isUploading = true
        appendMessages([message])
        co_launch { [weak self] in
            defer { message.isUploading = false }
            guard let self = self else { return }
            do {
                let sendMsgResult = try await(promise: self.viewModel.sendMessage(message, uploadDelegate: self))
                if case .fulfilled(let result) = sendMsgResult, result.isSuccess {
                    Log.i("消息发送成功……")
                    return
                }
                Log.e("消息发送失败……\(sendMsgResult)）")
            } catch(let error) {
                Log.e("消息发送失败……\(error)")
            }
        }
    }

    /// 新增一组消息
    /// - Parameter messages: 消息列表
    public func appendMessages(_ messages: Array<TIMMessage>) {
        let messageCount = self.messages.count
        var insertingPathes = Array<IndexPath>()
        for row in 0 ..< messages.count {
            let insertingRow = messageCount + row
            insertingPathes.append(IndexPath(row: insertingRow, section: 0))
        }
        tableView.beginUpdates()
        self.messages.append(contentsOf: messages)
        tableView.insertRows(at: insertingPathes, with: .automatic)
        tableView.endUpdates()
        scrollToBottom()
    }

    // MARK: 下拉加载更多历史消息
    public func insertMessages(_ messages: Array<TIMMessage>) {
        let newMessages = self.viewModel.messages
        self.messages.insert(contentsOf: newMessages, at: 0)
        self.tableView.reloadData()
        if newMessages.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(row: newMessages.count - 1, section: 0), at: .bottom, animated: false)
        }
        self.tableView.mj_header.endRefreshing()
    }

    public func scrollToBottom(animated: Bool = true) {
        if messages.count > 0 {
            let targetRow = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: targetRow, at: .bottom, animated: animated)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            delegate?.tableViewWillBeginDragging?(tableView)
        }
    }

    deinit {
        VoiceMessagePlayer.shared.removeListener(self)
    }
}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
//        Log.i("当前消息时间戳\(message.timestamp())")
        if let _ = message.getElem(0) as? TIMTextElem {
            let textCell = tableView.dequeueReusableCell(withIdentifier: textCellID) as! TextMessageCell
            textCell.message = message
            return textCell
        }
        if let voiceElem = message.getElem(0) as? TIMSoundElem {
            let voiceCell = tableView.dequeueReusableCell(withIdentifier: voiceCellID) as! VoiceMessageCell
            voiceCell.message = message
            let ratio = CGFloat(voiceElem.second) / CGFloat(180)
            let messageContentWidth = UIScreen.main.bounds.size.width * CGFloat(0.65) - 44 - 16 * 2
            voiceCell.voiceWidth = messageContentWidth * ratio
            return voiceCell
        }
        if let customElem = message.getElem(0) as? TIMCustomElem {
            let content = MessageContent(data: customElem.data!)
            message.content = content
            if let voiceContent = content as? VoiceMessageContent {
                let voiceCell = tableView.dequeueReusableCell(withIdentifier: voiceCellID) as! VoiceMessageCell
                voiceCell.message = message
                voiceCell.voiceContent = voiceContent
                voiceCell.delegate = self
                if VoiceMessagePlayer.shared.isPlaying, VoiceMessagePlayer.shared.message == message {
                    voiceCell.playButton.isSelected = true
                } else {
                    voiceCell.playButton.isSelected = false
                }
                let ratio = CGFloat(voiceContent.second) / CGFloat(180)
                let messageContentWidth = UIScreen.main.bounds.size.width * CGFloat(0.65) - 44 - 16 * 2
                let width = messageContentWidth * (ratio > 1 ? 1 : ratio)
                voiceCell.voiceWidth = width < 100 ? 100 : width
                return voiceCell
            }
            if let textContent = content as? TextMessageContent {
                let textCell = tableView.dequeueReusableCell(withIdentifier: textCellID) as! TextMessageCell
                textCell.message = message
                textCell.content = textContent.text
                return textCell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MessageCell
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewWillBeginDragging?(tableView)
        let message = messages[indexPath.row]
        delegate?.didSelectMessage?(message)
    }
}

extension MessageViewController: TIMMessageUpdateListener, TIMMessageRevokeListener, TIMMessageListener {
    public func onMessageUpdate(_ msgs: [Any]!) {
        Log.i("消息状态变化\(msgs.count)  \(msgs!)")
    }

    public func onRevokeMessage(_ locator: TIMMessageLocator!) {

    }

    public func onNewMessage(_ msgs: [Any]!) {
        Log.i("接收到了新消息\(msgs!)")
    }

    public func autoPlayFromMessage(msg: TIMMessage) {
        autoPlay = true
        VoiceMessagePlayer.shared.addListener(self)
        VoiceMessagePlayer.shared.playVoiceMessage(msg)
    }
}


extension MessageViewController: MessageFileLoaderDelegate {
    public func uploader(_ uploader: MessageFileUploader, onUploading msg: TIMMessage, progress: Int64, totalProgress: Int64) {
        Log.i("消息文件上传进度为\(progress) \(totalProgress)")
    }
}

extension MessageViewController: VoiceMessageCellDelegate, VoiceMessagePlayerListener {

    public func didClickPlayButton(_ button: UIButton, of cell: VoiceMessageCell, with message: TIMMessage) {
        guard let voiceContent = message.content as? VoiceMessageContent else {
            return
        }
        guard let _ = voiceContent.objectKey else {
            Log.e("无效的文件……objectKey为nil")
            return
        }
        delegate?.didSelectMessage?(message)
        let voicePlayer = VoiceMessagePlayer.shared
        voicePlayer.addListener(self)
        if voicePlayer.isPlaying, voicePlayer.message?.msgId() == message.msgId() {
            autoPlay = false
            voicePlayer.stopPlaying()
            return
        }
        if voicePlayer.isPlaying, voicePlayer.message?.msgId() != message.msgId() {
            autoPlay = true
            voicePlayer.stopPlaying()
            voicePlayer.playVoiceMessage(message)
            return
        }
        voicePlayer.playVoiceMessage(message)
    }

    public func onPlayingVoiceMessageStatusChanged(_ status: VoiceMessagePlayStatus, message: TIMMessage) {
        Log.i("音频播放状态变化了\(status) \(message.msgId()!)")
        guard let index = self.messages.firstIndex(of: message) else {
            return
        }
        guard let voiceCell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? VoiceMessageCell else {
            return
        }
        switch status {
        case .startPlaying:
            Log.i("开始播放")
            delegate?.didSelectMessage?(message)
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: true)
            voiceCell.playButton.isSelected = true
        case .downloading(let progress, let totalProgress):
            Log.i("正在下载\(progress) \(totalProgress)")
        case .stop:
            voiceCell.playButton.isSelected = false
            if autoPlay {
                if let voiceMessage = viewModel.voiceMessage(after: message) {
                    VoiceMessagePlayer.shared.playVoiceMessage(voiceMessage)
                }
            }
            Log.i("停止播放")
        case .error(let error):
            voiceCell.playButton.isSelected = false
            Log.i("播放失败\(error)")
        case .playProgress(let current, let duration):
            Log.i("播放进度\(current)  \(duration)")
        }
    }
}
