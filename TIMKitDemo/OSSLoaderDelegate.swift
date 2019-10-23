//
//  OSSLoaderDelegate.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
@objc public protocol OSSLoaderDelegate {
    @objc optional func downloader(_ loader: OSSDownloader, downloading request: OSSGetObjectRequest, progress: Int64, totalProgress: Int64);
    @objc optional func uploader(_ uploader: OSSUploader, putting request: OSSPutObjectRequest, progress: Int64, totalProgress: Int64);
}
