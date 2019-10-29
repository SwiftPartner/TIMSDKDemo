//
//  EXVideoMessageContent.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/29.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift
import AVFoundation
import CommonTools

public extension VideoMessageContent {

    struct Holder {
        public static var mp4Exporter: AVAssetExportSession?
    }

    class func generateVideoMessage(withVideoUrl url: URL) -> Promise<TIMMessage> {
//        encodeVideo(videoUrl: url) { url in
//            Log.i("转换结果:\(url)")
//        }
        let promise = Promise<TIMMessage>()
        DispatchQueue.global().async {
            guard let thumbnail = generateThumbnail(withVideoUrl: url),
                let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
                    promise.reject(error: CustomError.thumbnailFailed)
                    return
            }
            let videoContent = VideoMessageContent()
            let videoName = THelper.genVideoName(nil)!
            let thumbnailUrl = URL.imageURL(withName: videoName)
            let videoURL = URL.videoURL(withName: videoName)
            videoContent.path = videoURL.path
            if !FileManager.default.fileExists(atPath: URL.videoDirectory.path) {
                try! FileManager.default.createDirectory(at: .videoDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !FileManager.default.fileExists(atPath: thumbnailUrl.path) {
                if !FileManager.default.createFile(atPath: thumbnailUrl.path, contents: thumbnailData, attributes: nil) {
                    promise.reject(error: CustomError.thumbnailFailed)
                    return
                }
            }
            videoContent.type = .video
            videoContent.objectKey = videoName
            videoContent.bucketName = BucketName.video.rawValue
            videoContent.width = thumbnail.width
            videoContent.height = thumbnail.height
            videoContent.thumbnailKey = videoName
            videoContent.thumbnailBucket = BucketName.image.rawValue
            co_launch {
                let result = try! await(promise: exportMP4(fromVideoUrl: url, withObjectKey: videoName))
                Holder.mp4Exporter = nil
                if case .fulfilled(let success) = result {
                    if !success {
                        promise.reject(error: CustomError.exportMP4Failed)
                        return
                    }
                    let message = TIMMessage.message(content: videoContent)
                    message.content = videoContent
                    promise.fulfill(value: message)
                }
            }
        }
        return promise
    }

    private class func exportMP4(fromVideoUrl url: URL, withObjectKey objKey: String) -> Promise<Bool> {
        let promise = Promise<Bool>()
        let asset = AVAsset(url: url)
        let targetURL = URL.videoURL(withName: objKey)
        if FileManager.default.fileExists(atPath: targetURL.path) {
            promise.fulfill(value: true)
            return promise
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
            promise.fulfill(value: false)
            return promise
        }
        Holder.mp4Exporter = exportSession
        exportSession.outputURL = targetURL
        exportSession.outputFileType = .mp4
        let start = CMTime(seconds: 0, preferredTimescale: 0)
        exportSession.timeRange = CMTimeRange(start: start, duration: asset.duration)
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                Log.i("mp4文件导出成功……")
                promise.fulfill(value: true)
            case .failed:
                fallthrough
            case .cancelled:
                Log.i("mp4文件导出失败……")
                promise.fulfill(value: false)
            default:
                Log.i("mp4文件导出其他状态……")
                Log.i("hahaha")
            }
        }
        return promise
    }

    /// 为提供的视频生成视频截图
    /// - Parameter url: 视频URL地址
    public class func generateThumbnail(withVideoUrl url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let time = CMTime(value: 1, timescale: 1)
            let imgRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imgRef)
        } catch(let error) {
            Log.e("为视频创建缩略图失败\(error)")
        }
        return nil
    }
}
