//
//  EXImageMessageContent.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/25.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public extension ImageMessageContent {

    public func storage() {
        guard let image = image else {
            return
        }
        guard let imageData = image.pngData() else {
            return
        }
        let count = imageData.count
    }

}
