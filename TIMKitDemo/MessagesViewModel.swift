//
//  MessagesViewModel.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift
import CommonTools
import AVFoundation

public class MessagesViewModel {
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

    private func getMessage(_ count: Int32, last: TIMMessage?, succ: @escaping TIMGetMsgSucc, fail: @escaping TIMFail) {
        let reachability = OSSReachability(hostName: "www.baidu.com")
        let status = reachability?.currentReachabilityStatus()
        if status?.rawValue == 0 {
            conversation.getLocalMessage(count, last: last, succ: succ, fail: fail)
        } else {
            conversation.getMessage(count, last: last, succ: succ, fail: fail)
        }
    }


    /// 加载消息对话中的消息列表
    /// - Parameter refresh: 是否刷新消息 true 重新加载消息， false加载更多
    public func loadMessages() -> Promise<(TICResult)> {
        let lastMsg = messages.first ?? conversation.getLastMsg()
        let promise = Promise<TICResult>()
        getMessage(20, last: lastMsg, succ: { [weak self] msgs in
            if let self = self, let msgs = msgs as? [TIMMessage] {
                self.hasMoreMessages = msgs.count >= 20
                self.messages = msgs
                if self.messages.first == msgs.last {
                    self.hasMoreMessages = false
                    self.messages = []
                }
                self.messages.reverse()
                promise.fulfill(value: TICResult(code: 0, desc: "消息拉取成功"))
            }
        }, fail: { (code, desc) in
            promise.fulfill(value: TICResult(code: code, desc: desc ?? "消息拉取失败"))
            Log.i("会话列表获取失败\(code) \(desc ?? "")")
        })
        return promise
    }

    /// 发送消息
    /// - Parameter msg: 消息对象
    /// - Parameter uploadDelegate: 发送文件时，监听文件上传进度
    public func sendMessage(_ msg: TIMMessage, uploadDelegate: MessageFileLoaderDelegate? = nil) -> Promise<TICResult> {
        if let voiceContent = msg.content as? VoiceMessageContent {
            let voiceUrl = URL(fileURLWithPath: voiceContent.path!)
            let promise = self.uploadFile(voiceUrl, of: msg, to: .voice, uploadDelegate: uploadDelegate).then { [weak self] putResult -> Promise<TICResult> in
                guard let self = self else { return Promise<TICResult>() }

                return self.conversation.sendMessage(msg)
            }
            return promise
        }
        if let imageContent = msg.content as? ImageMessageContent {
            let voiceUrl = URL(fileURLWithPath: imageContent.path!)
            let promise = self.uploadFile(voiceUrl, of: msg, to: .image, uploadDelegate: uploadDelegate).then { [weak self] putResult -> Promise<TICResult> in
                guard let self = self else { return Promise<TICResult>() }
                return self.conversation.sendMessage(msg)
            }
            return promise
        }
        if let videoContent = msg.content as? VideoMessageContent {
            let objectKey = videoContent.objectKey!
            let videoUrl = URL.videoURL(withName: objectKey)
            let thumbnailUrl = URL.imageURL(withName: objectKey)
            let promise = self.uploadFile(videoUrl, of: msg, to: .video, uploadDelegate: uploadDelegate).then { [weak self] putResult -> Promise<OSSPutObjectResult> in
                guard let self = self else {
                    return Promise<OSSPutObjectResult>()
                }
                return self.uploadFile(thumbnailUrl, of: msg, to: .image, uploadDelegate: uploadDelegate)
            }.then { [weak self] putResult -> Promise<TICResult> in
                guard let self = self else {
                    return Promise<TICResult>()
                }
                return self.conversation.sendMessage(msg)
            }
            return promise
        }
        return conversation.sendMessage(msg)
    }

    /// 上传文件到阿里云OSS
    /// - Parameter url: 文件本地路径
    /// - Parameter bucketName
    public func uploadFile(_ url: URL, of message: TIMMessage, to bucketName: BucketName, uploadDelegate: MessageFileLoaderDelegate? = nil) -> Promise<OSSPutObjectResult> {
        let objectKey = url.lastPathComponent
        let request = OSSUploader.buildPutObjectRequest(withFilePath: url, bucketName: bucketName.rawValue, objectKey: objectKey)
        let uploader = MessageFileUploader(request: request, message: message)
        uploader.delegate = uploadDelegate
        return uploader.upload()
    }


    public func voiceMessage(in messageList: [TIMMessage], after message: TIMMessage) -> TIMMessage? {
        guard let index = messageList.firstIndex(of: message) else {
            return nil
        }
        guard index + 1 < messageList.count else {
            return nil
        }
        let message = messageList[index + 1]
        if message.content?.type == MessageType.voice {
            return message
        }
        return voiceMessage(in: messageList, after: message)
    }

    public func downloadFiles(from message: TIMMessage, downloadDelegate: MessageFileDownloaderDelegate) {

    }



}
