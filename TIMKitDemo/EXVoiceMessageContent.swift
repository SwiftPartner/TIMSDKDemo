//
//  EXVoiceMessageContent.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/23.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import AVFoundation
import CommonTools

public extension VoiceMessageContent {

    class func messageContent(voiceLoalUrl: URL) -> VoiceMessageContent? {
        let asset = AVURLAsset(url: voiceLoalUrl)
        let duration = Int(ceil(CMTimeGetSeconds(asset.duration) - 0.1))
        do {
            let atts = try FileManager.default.attributesOfItem(atPath: voiceLoalUrl.path)
            let length = atts[.size] as! Int
            let messageContent = VoiceMessageContent(dataSize: length, second: duration)
            messageContent.path = voiceLoalUrl.path
            messageContent.objectKey = voiceLoalUrl.lastPathComponent
            messageContent.bucketName = BucketName.voice.rawValue
            return messageContent
        } catch (let error) {
            Log.e("从本地创建VoiceMessageContent对象出错\(error)")
            return nil
        }
    }
}
