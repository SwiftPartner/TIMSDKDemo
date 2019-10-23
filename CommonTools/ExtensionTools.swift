//
//  ExtensionTools.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/18.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public extension Data {
    var isJSON: Bool {
        return JSONSerialization.isValidJSONObject(self)
    }
}

public extension String {

}

public extension UIScreen {
    var width: CGFloat { bounds.size.width }
    var height: CGFloat { bounds.size.height }
}

public extension UIView {
    var width: CGFloat { bounds.size.width }
    var height: CGFloat { bounds.size.height }
    var size: CGSize { bounds.size }
    
    func makeCorner(radius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat = 0) {
        layer.cornerRadius = radius
        layer.borderColor = borderColor?.cgColor
        layer.borderWidth = borderWidth
        layer.masksToBounds = true
    }

    func makeShadow(color: UIColor = .gray, offset: CGSize = CGSize(width: 0, height: 3), opacity: Float = 0.3, radius: CGFloat = 2, path: CGPath? = nil) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        if let path = path {
            layer.shadowPath = path
        }
    }
}
