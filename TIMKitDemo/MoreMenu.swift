//
//  MessageMenu.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class MoreMenu {
    public var icon: UIImage
    public var title: String
    public var type: MoreMenuType

    init(icon: UIImage, title: String, type: MoreMenuType) {
        self.icon = icon
        self.title = title
        self.type = type
    }
}
