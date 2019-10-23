//
//  MessageFileDownloader.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/22.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift

@objc public protocol MessageFileDownloaderDelegate {
    @objc optional func fileDownloader(_ downloader: MessageFileDownloader, download message: TIMMessage, progress: Int64, totalProgress: Int64)
}

@objc public class MessageFileDownloader: NSObject, OSSLoaderDelegate {
    private var request: OSSGetObjectRequest
    private var message: TIMMessage
    private var downloader: OSSDownloader
    public weak var delegate: MessageFileDownloaderDelegate?

    public init(request: OSSGetObjectRequest, message: TIMMessage) {
        self.request = request
        self.message = message
        downloader = OSSDownloader(getObjectRequest: request)
        super.init()
        downloader.delegate = self
    }

    public func download() -> Promise<OSSGetObjectResult> {
        return downloader.download()
    }

    public func downloader(_ loader: OSSDownloader, downloading request: OSSGetObjectRequest, progress: Int64, totalProgress: Int64) {
        delegate?.fileDownloader?(self, download: message, progress: progress, totalProgress: totalProgress)
    }
}
