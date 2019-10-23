//
//  UnionMessageElement.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class UnionMessageElement: TIMElem {
    public var type: MessageType
    public var jsonContent: String
    
    public init(type: MessageType, jsonContent: String) {
        self.type = type
        self.jsonContent = jsonContent
        super.init()
    }
}
