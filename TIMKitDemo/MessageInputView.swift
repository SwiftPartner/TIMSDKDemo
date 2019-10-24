//
//  MessageInputView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import SnapKit
import CommonTools

@objc public protocol MessageInputViewDelegate {
    @objc optional func messageInputView(_ inputView: MessageInputView, didEndEditing text: String);
    @objc optional func messageInputView(_ inputView: MessageInputView, didHeightChanged height: CGFloat)
}

public class MessageInputView: UIView {

    public let inputBarHeight: CGFloat = 50
    private weak var inputBar: MessageInputBar!
    private weak var recordView: RecordAudioView!
//    public weak var auditionView: AuditionView!
    public weak var moreView: InputMoreView!
    private var containerHeightConstraint: Constraint!
    private var containerHeight: CGFloat = 0 {
        willSet {
            if newValue == containerHeight { return }
            delegate?.messageInputView?(self, didHeightChanged: newValue + inputBarHeight)
            isUserInteractionEnabled = false
            containerHeightConstraint.update(offset: newValue)
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }) { _ in self.isUserInteractionEnabled = true }
        }
    }

    public weak var delegate: MessageInputViewDelegate?

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let inputBar = MessageInputBar()
        self.inputBar = inputBar
        inputBar.delegate = self
        addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self)
            make.height.equalTo(inputBarHeight)
        }

        let container = UIView()
        container.clipsToBounds = true
        addSubview(container)
        container.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self)
            self.containerHeightConstraint = make.height.equalTo(0).constraint
            make.top.equalTo(inputBar.snp.bottom)
        }

        let recordView = RecordAudioView()
        recordView.backgroundColor = .yellow
        recordView.isHidden = true
        self.recordView = recordView
        container.addSubview(recordView)
        recordView.snp.makeConstraints { make in
            make.edges.equalTo(container)
        }

        let moreView = InputMoreView()
        moreView.isHidden = true
        moreView.backgroundColor = .purple
        self.moreView = moreView
        container.addSubview(moreView)
        moreView.snp.makeConstraints { make in
            make.edges.equalTo(container)
        }
    }

    // MARK: 清空文本输入框内容
    public func resetText(_ text: String?) {
        inputBar.textField?.text = text
    }

    // MARK: 关闭语音输入视图 & 更多视图，只显示MessageInputBar
    public func showInputBarOnly() {
//        if !audioInputView.isHidden {
//            showAudioInutView(false)
//            return
//        }
//        if !inputMenuView.isHidden {
//            showMenuView(false)
//            return
//        }
    }

}

extension MessageInputView: MessageInputBarDelegate {

    // MARK: 点击了语音按钮，打开、关闭语音输入视图
    public func didClickVoiceButton() {
        endEditing(true)
        recordView.isHidden = !recordView.isHidden
        if recordView.isHidden, moreView.isHidden {
            containerHeight = 0
        } else {
            moreView.isHidden = true
            containerHeight = 140
        }
    }

    // MARK: 点击了更多按钮，打开、关闭更多视图
    public func didClickMoreButton() {
        moreView.isHidden = !moreView.isHidden
        if recordView.isHidden, moreView.isHidden {
            containerHeight = 0
        } else {
            recordView.isHidden = true
            containerHeight = 140
        }
    }

    // MARK: 文本输入完成事件监听
    public func didEndEditing(text: String) {
        endEditing(true)
        delegate?.messageInputView?(self, didEndEditing: text)
    }
}
