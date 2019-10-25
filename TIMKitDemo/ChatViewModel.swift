
//
//  ChatViewModel.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift
import CommonTools

public class ChatViewModel {

    private(set) public var conversation: TIMConversation
    private(set) public lazy var messages: [TIMMessage] = Array()
    private var lastMsg: TIMMessage?
    private(set) public var hasMoreMessages: Bool = true

    public init(conversation: TIMConversation) {
        self.conversation = conversation
    }

}
