//
//  OSSLoaderDelegate.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
@objc public protocol OSSLoaderDelegate {
    @objc optional func onDownloading();
    @objc optional func uploader(_ uploader: OSSUploader, putting request: OSSPutObjectRequest, progress: Int64, totalProgress: Int64);
}
