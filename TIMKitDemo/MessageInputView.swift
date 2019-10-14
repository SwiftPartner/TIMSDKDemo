//
//  MessageInputView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public class MessageInputView: UIView {
    
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
        addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.left.right.top.equalTo(self)
            make.height.equalTo(50)
        }
    }
}
