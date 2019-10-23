//
//  MessageInputView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import SnapKit

@objc public protocol MessageInputViewDelegate {
    @objc optional func messageInputView(_ inputView: MessageInputView, didEndEditing text: String);
    @objc optional func messageInputView(_ inputView: MessageInputView, didHeightChanged height: CGFloat)
}

public class MessageInputView: UIView, MessageInputBarDelegate {
    
    private weak var inputBar:MessageInputBar!
    private weak var audioInputView: UIView!
    public weak var auditionView: AuditionView!
    public weak var recordButton: AudioRecordButton!
    public weak var timeLabel: UILabel!
    public weak var auditionViewDelegate: AuditionViewDelegate? {
        didSet {
            auditionView.delegate = auditionViewDelegate
        }
    }
    public weak var delegate: MessageInputViewDelegate?
    public weak var recordButtonDelegate: AudioRecordButtonDelegate? {
        didSet {
            recordButton.delegate = recordButtonDelegate
        }
    }
    private var showAudioInutView: Bool = false {
        didSet {
            self.audioInputView.isHidden = !showAudioInutView
            let height: CGFloat = showAudioInutView ? 140 : 0
            self.delegate?.messageInputView?(self, didHeightChanged: height)
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.layoutIfNeeded()
                self?.superview?.layoutIfNeeded()
            })
        }
    }
    
    /// 是否显示试听视图
    public var showAuditionView: Bool = false {
        didSet {
            auditionView.isHidden = false
            let show = showAuditionView
            auditionView.alpha = show ? 0 : 1
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.auditionView.alpha = show ? 1 : 0
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.auditionView.isHidden = !show
            })
        }
    }

    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .groupColor
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.height.greaterThanOrEqualTo(50)
        }
        let inputBar = MessageInputBar()
//        inputBar.backgroundColor = .gray
        self.inputBar = inputBar
        inputBar.delegate = self
        stackView.addArrangedSubview(inputBar)

        let audioInputView = UIView()
        self.audioInputView = audioInputView
//        audioInputView.backgroundColor = .groupColor
        stackView.addArrangedSubview(audioInputView)
        audioInputView.snp.makeConstraints { make in
            make.left.right.equalTo(self)
            make.height.equalTo(140)
        }
        audioInputView.isHidden = true
        
        let timeLabel = UILabel()
        timeLabel.isHidden = true
        timeLabel.text = "0/\(180)"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        audioInputView.addSubview(timeLabel)
        self.timeLabel = timeLabel
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(audioInputView).offset(10)
            make.centerX.equalTo(audioInputView)
        }
    
        let recordButton = AudioRecordButton()
        self.recordButton = recordButton
        recordButton.setup(recordMode: .tapToRecord)
        audioInputView.addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.top.equalTo(audioInputView).offset(30)
            make.centerX.equalTo(audioInputView)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        audioInputView.clipsToBounds = true
        let tipsLabel = UILabel()
        tipsLabel.text = "点击录音"
        tipsLabel.font = UIFont.systemFont(ofSize: 12)
        audioInputView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalTo(recordButton.snp.bottom)
            make.bottom.centerX.equalTo(audioInputView)
        }
        stackView.sizeToFit()
        
        let auditionView = AuditionView()
        self.auditionView = auditionView
        showAuditionView = false
        audioInputView.addSubview(auditionView)
        auditionView.snp.makeConstraints { make in
            make.edges.equalTo(audioInputView)
        }
    }
    
    // MARK: 清空文本输入框内容
    public func resetText(_ text: String?) {
        inputBar.textField?.text = text
    }
    
    // MARK: 点击了语音按钮，打开、关闭语音输入视图
    public func didClickVoiceButton() {
        endEditing(true)
        showAudioInutView = !showAudioInutView
    }
    
    // MARK: 点击了更多按钮，打开、关闭更多视图
    public func didClickMoreButton() {
        showAudioInutView = false
        endEditing(true)
    }
    
    // MARK: 文本输入完成事件监听
    public func didEndEditing(text: String) {
        endEditing(true)
        delegate?.messageInputView?(self, didEndEditing: text)
    }
    
    // MARK: 关闭语音输入视图 & 更多视图，只显示MessageInputBar
    public func showInputBarOnly() {
        if !showAudioInutView {
            return
        }
        showAudioInutView = false
    }
    
}
