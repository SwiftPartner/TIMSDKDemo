//
//  EXMessage.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/23.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public extension TIMMessage {
    
    class func message(content: MessageContent) -> TIMMessage {
        let message = TIMMessage()
        let elem = TIMCustomElem()
        elem.data = content.jsonData()
        message.content = content
        message.add(elem)
        return message
    }
}
