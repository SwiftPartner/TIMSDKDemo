//
//  MessageViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import SnapKit

@objc public protocol MessageViewControllerDelegate {
    @objc optional func tableViewWillBeginDragging(_ tableView: UITableView)
}

public class MessageViewController: BaseViewController {
    
    public private(set) weak var tableView: UITableView!
    
    let cellID = "cell_ID"
    let textCellID = "text_cell"
    let imageCellID = "image_cell"
    let voiceCellID = "voice_cell"
    let videoCellID = "video_cell"
    
    private(set) public lazy var messages: Array<TIMMessage> = []
    public weak var delegate: MessageViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    // MARK: 创建TableView
    private func setupTableView() {
        let tableView = UITableView()
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
        //        showLoadingView = true
    }
    
    /// 消息发送成功
    /// - Parameter message: 消息
    public func didSendMessage(_ message: TIMMessage) {
        appendMessages([message])
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
}

extension MessageViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
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
            if let voiceContent = content as? VoiceMessageContent {
                let voiceCell = tableView.dequeueReusableCell(withIdentifier: voiceCellID) as! VoiceMessageCell
                voiceCell.message = message
                voiceCell.voiceContent = voiceContent
                let ratio = CGFloat(voiceContent.second) / CGFloat(180)
                let messageContentWidth = UIScreen.main.bounds.size.width * CGFloat(0.65) - 44 - 16 * 2
                let width = messageContentWidth * (ratio > 1 ? 1 : ratio)
                voiceCell.voiceWidth = width < 100 ? 100 : width
                return voiceCell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MessageCell
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.tableViewWillBeginDragging?(tableView)
    }
    
    
    
}
