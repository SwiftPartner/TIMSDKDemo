//
//  OSSMessageLoaderDelegate.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

@objc public protocol MessageFileLoaderDelegate {
    @objc optional func uploader(_ uploader: MessageFileUploader, onUploading msg:TIMMessage, progress: Int64, totalProgress: Int64);
}
