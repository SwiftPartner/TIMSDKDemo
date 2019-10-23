//
//  OSSDownloader.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/22.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift

@objc public class OSSDownloader: OSSLoader {

    private var getObjectRequest: OSSGetObjectRequest
    public override var delegate: OSSLoaderDelegate? {
        didSet {
            getObjectRequest.downloadProgress = { [weak self] _, totalBytesWritten, totalBytesExpectedToSend in
                if let self = self {
                    self.delegate?.downloader?(self, downloading: self.getObjectRequest, progress: totalBytesWritten, totalProgress: totalBytesExpectedToSend)
                }
            }
        }
    }

    public init(getObjectRequest: OSSGetObjectRequest) {
        self.getObjectRequest = getObjectRequest
        super.init()
    }

    public static func buildGetObjectRequest(bucketname: String, objectKey: String, targetFileURL: URL) -> OSSGetObjectRequest {
        let request = OSSGetObjectRequest()
        request.bucketName = bucketname
        request.objectKey = objectKey
        request.downloadToFileURL = targetFileURL
        return request
    }

    public func download() -> Promise<OSSGetObjectResult> {
        let promise = Promise<OSSGetObjectResult>()
        OSSManager.shared.client.getObject(getObjectRequest).continue({ task -> Void in
            guard let result = task.result as? OSSGetObjectResult else {
                let error = task.error ?? OSSError.unknow
                promise.reject(error: error)
                return
            }
            promise.fulfill(value: result)
        }, cancellationToken: nil).waitUntilFinished()
        return promise
    }

}
