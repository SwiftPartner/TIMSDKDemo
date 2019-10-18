//
//  MessageInputBar.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

@objc public protocol MessageInputBarDelegate {
    @objc optional func didEndEditing(text:String);
    @objc optional func didClickVoiceButton();
    @objc optional func didClickMoreButton();
}

public class MessageInputBar: UIView, UITextViewDelegate {

    private weak var textField: UITextView?
    private weak var voiceBtn: UIButton?
    private weak var moreBtn: UIButton?
    private weak var textViewHeight: SnapKit.Constraint!
    public weak var delegate: MessageInputBarDelegate? {
        didSet {
            if let delegate = delegate {
                if let _ = delegate.didClickVoiceButton {
                    voiceBtn?.addTarget(delegate, action: #selector(delegate.didClickVoiceButton), for: .touchUpInside)
                }
                if let _ = delegate.didClickMoreButton {
                    moreBtn?.addTarget(delegate, action: #selector(delegate.didClickMoreButton), for: .touchUpInside)
                }
            }
        }
    }
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private(set) public lazy var textObservable: Observable<String>? = {
        return textField?.rx.text.orEmpty.asObservable()
    }()
    
    
    private func setup() {
        let dividerView = UIView()
        dividerView.backgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.5401078345)
        addSubview(dividerView)
        dividerView.snp.makeConstraints { make in
            make.left.right.top.equalTo(self)
            make.height.equalTo(0.5)
        }
        backgroundColor = .white
        let voiceBtn = UIButton(type: .system)
        self.voiceBtn = voiceBtn
        voiceBtn.setContentHuggingPriority(.required, for: .horizontal)
        voiceBtn.setTitle("语音", for: .normal)
        addSubview(voiceBtn)
        voiceBtn.snp.makeConstraints { make in
            make.left.centerY.equalTo(self)
            make.width.equalTo(64)
        }
        let textField = UITextView()
        textField.backgroundColor = .groupColor
        textField.makeCorner(radius: 6, borderColor: .white, borderWidth: 1)
        self.textField = textField
        textField.delegate = self
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(voiceBtn.snp.right)
            let textViewHeight = make.height.equalTo(34).constraint
            self.textViewHeight = textViewHeight
            make.top.equalTo(self).offset(8)
            make.bottom.equalTo(self).offset(-8)
        }
        textField.sizeToFit()
        let moreBtn = UIButton(type: .system)
        self.moreBtn = moreBtn
        moreBtn.setTitle("更多", for: .normal)
        moreBtn.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.width.equalTo(64)
            make.left.equalTo(textField.snp.right)
            make.right.equalTo(self)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didEndEditing?(text: textView.text)
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let contentSize = textView.sizeThatFits(CGSize(width: textView.bounds.size.width, height: CGFloat(MAXFLOAT)))
        textViewHeight.update(offset: contentSize.height)
        layoutIfNeeded()
    }
}

