
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
    
    public func startRecord() throws {
        
    }
    
    
    public class func createAndJoingGroup(_ group: String) -> Promise<TICResult> {
        let groupInfo = TIMCreateGroupInfo()
        groupInfo.groupType = "Public"
        groupInfo.group = group
        groupInfo.groupName = group
        return TIMManager.sharedInstance()!.createAndJoinGroup(groupInfo)
    }
    
    
    /// 加载消息对话中的消息列表
    /// - Parameter refresh: 是否刷新消息 true 重新加载消息， false加载更多
    public func loadMessages() -> Promise<(TICResult)> {
        let lastMsg = messages.first
        let promise = Promise<TICResult>()
        conversation.getMessage(20, last: lastMsg, succ: {[weak self] msgs in
            if let self = self, let msgs = msgs as? [TIMMessage] {
                self.hasMoreMessages = msgs.count >= 20
                self.messages = msgs
                promise.fulfill(value: TICResult(code: 0, desc: "消息拉取成功"))
            }
            }, fail: { (code, desc) in
                promise.fulfill(value: TICResult(code: code, desc: desc ?? "消息拉取失败"))
                Log.i("会话列表获取失败\(code) \(desc ?? "")")
        })
        return promise
    }
    
    
    
    /// 上传文件到阿里云OSS
    /// - Parameter url: 文件本地路径
    /// - Parameter bucketName
    public func uploadFile(_ url: URL, bucketName: BucketName) {
        let objectKey = url.lastPathComponent
        let request = OSSUploader.buildPutObjectRequest(withFilePath: url, bucketName: bucketName.rawValue, objectKey: objectKey)
        let uploader = OSSUploader(request: request)
        co_launch {
            let uploadResult = try await(promise: uploader.upload())
            switch uploadResult {
            case .fulfilled(let result):
                Log.i("文件上传成功……")
            case .rejected(let erro):
                Log.i("文件上传失败……")
            }
        }
    }
    
}
