//
//  ChatViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SnapKit

public class ChatViewController: BaseViewController {
    
    private weak var messageInputView: MessageInputView!
    private var messageInputViewHeight: Constraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        addMessageInputView()
    }
    
    private func addMessageInputView() {
        let inputView = MessageInputView()
        inputView.backgroundColor = .red
        view.addSubview(inputView)
        inputView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            let messageInputViewHeight = make.height.equalTo(50).constraint
            self.messageInputViewHeight = messageInputViewHeight
        }
    }
    
}
