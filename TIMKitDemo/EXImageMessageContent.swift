//
//  EXImageMessageContent.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/25.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift

public extension ImageMessageContent {

    class func generateImageMessage(image: UIImage?) -> Promise<TIMMessage> {
        let promise = Promise<TIMMessage>()
        guard let image = image else {
            promise.reject(error: CustomError.compressImageFailed)
            return promise
        }
        image.limitImageSizeAsync(inWidth: 720, dataCount: 1024 * 1024 * 2) { data in
            guard let data = data else {
                promise.reject(error: CustomError.compressImageFailed)
                return
            }
            let imageName = THelper.genImageName(nil) as String
            let imageURL = URL.imageURL(withName: imageName)
            let imagePath = imageURL.path
            FileManager.createFileAsync(atPath: imagePath, contents: data, attributes: nil) { success in
                if !success {
                    promise.reject(error: CustomError.saveFileFailed)
                    return
                }
                let image = UIImage(data: data)
                let messageContent = ImageMessageContent(image: image!)
                messageContent.path = imagePath
                messageContent.objectKey = imageName
                let imageMessage = TIMMessage.message(content: messageContent)
                promise.fulfill(value: imageMessage)
            }
        }
        return promise
    }
}
