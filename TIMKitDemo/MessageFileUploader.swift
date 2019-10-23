//
//  OSSMessageUploader.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift

@objc public class MessageFileUploader: NSObject, OSSLoaderDelegate {
    
    private(set) public var message: TIMMessage
    public var uploader:  OSSUploader
    public weak var delegate: MessageFileLoaderDelegate? {
        didSet {
            uploader.delegate = self
        }
    }
    
    public init(request: OSSPutObjectRequest, message: TIMMessage) {
        self.message = message
        self.uploader = OSSUploader(request: request)
        super.init()
    }
    
    public func uploader(_ uploader: OSSUploader, putting request: OSSPutObjectRequest, progress: Int64, totalProgress: Int64) {
        delegate?.uploader?(self, onUploading: message, progress: progress, totalProgress: totalProgress)
    }
    
    public func upload() -> Promise<OSSPutObjectResult>{
        return uploader.upload()
    }
}
