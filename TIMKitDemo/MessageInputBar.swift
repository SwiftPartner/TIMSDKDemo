//
//  MessageInputBar.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public class MessageInputBar: UIView {
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let voiceBtn = UIButton()
        voiceBtn.setContentHuggingPriority(.required, for: .horizontal)
        voiceBtn.setTitle("语音", for: .normal)
        addSubview(voiceBtn)
        voiceBtn.snp.makeConstraints { make in
            make.left.centerY.equalTo(self)
            make.width.equalTo(64)
        }
        let textField = UITextField()
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textField.borderStyle = .roundedRect
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(voiceBtn.snp.right)
            make.centerY.equalTo(self)
        }
        let moreBtn = UIButton()
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
}

