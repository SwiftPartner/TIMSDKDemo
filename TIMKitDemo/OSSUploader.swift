//
//  OSSUploader.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift
import CommonTools

public class OSSUploader: OSSLoader {
    
    private var request: OSSPutObjectRequest
    
    public override var delegate: OSSLoaderDelegate? {
        didSet {
            request.uploadProgress = { current, progress, total in
                DispatchQueue.main.async { [weak self]  in
                    if let self = self {
                        Log.i("上传进度为\(current) \(progress) \(total)")
                        self.delegate?.uploader?(self, putting: self.request, progress: progress, totalProgress: total)
                    }
                }
            }
        }
    }
    
    public init(request: OSSPutObjectRequest) {
        self.request = request
    }
    
    public static func buildPutObjectRequest(withFilePath path: URL, bucketName: String, objectKey key: String) -> OSSPutObjectRequest {
          let request = OSSPutObjectRequest()
          request.bucketName = bucketName
          request.uploadingFileURL = path
          request.objectKey = key
          return request
    }
    
    public func upload() -> Promise<OSSPutObjectResult> {
        let promise = Promise<OSSPutObjectResult>()
        OSSManager.shared.client.putObject(request).continue({ task -> Void in
            if let putObjResult = task.result as? OSSPutObjectResult {
                promise.fulfill(value: putObjResult)
                return
            }
            promise.reject(error: task.error ?? OSSError.unknow)
        }, cancellationToken: nil).waitUntilFinished()
        return promise
    }
    
}
