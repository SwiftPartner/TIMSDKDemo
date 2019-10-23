//
//  TIMExtension.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public extension TIMMessage {
    
    private struct TIMMessageHolder {
        public static var content = [String: MessageContent]()
        public static var loading = [String: Bool]()
    }
    
    var content: MessageContent? {
        set{
            TIMMessageHolder.content[msgId()] = newValue
        }
        get{
            return TIMMessageHolder.content[msgId()]
        }
    }
    
    var isUploading: Bool {
        set{
            TIMMessageHolder.loading[msgId()] = newValue
        }
        get {
            return TIMMessageHolder.loading[msgId()] ?? false
        }
    }
}
