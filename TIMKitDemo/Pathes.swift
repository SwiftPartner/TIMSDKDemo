//
//  Pathes.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
public extension URL {

    private(set) static var voiceDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let voiceDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("voice")
        return voiceDir
    }()

    private(set) static var imageDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let imgDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("image")
        return imgDir
    }()

    private(set) static var videoDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let videoDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("video")
        return videoDir
    }()

    static func videoURL(withName name: String) -> URL {
        return videoDirectory.appendingPathComponent(name)
    }

    static func voiceURL(withName name: String) -> URL {
        return voiceDirectory.appendingPathComponent(name)
    }

    static func imageURL(withName name: String) -> URL {
        return imageDirectory.appendingPathComponent(name)
    }
}

public enum CustomError: Error {
    case compressImageFailed
    case saveFileFailed
    case thumbnailFailed
    case exportMP4Failed
}
