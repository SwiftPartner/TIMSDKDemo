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

public extension UIImage {
    var width: CGFloat { size.width }
    var height: CGFloat { size.height }

    var imageSizeInMB: Double {
        guard let count = pngData()?.count else {
            return 0
        }
        return Double(count) / 1024.0 / 1024.0
    }

    /// 测量图片存储为文件后的大小
    func measureRealSize() -> CGFloat {
        var tempURL = FileManager.default.temporaryDirectory
        let tempFilePath = tempURL.appendingPathComponent("hhh").path
        let success = FileManager.default.createFile(atPath: tempFilePath, contents: pngData(), attributes: nil)
        if success {
            let url = URL(fileURLWithPath: tempFilePath)
            let data = try! Data(contentsOf: url)
            let byteCount = data.count
            let displaySize = ByteCountFormatter.string(fromByteCount: Int64(byteCount), countStyle: .file)
            return CGFloat(Float(displaySize)!)
        }
        return 0
    }

    func fixedOrientation() -> UIImage? {

        guard imageOrientation != UIImage.Orientation.up else {
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        default:
            return self
        }
        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        default:
            return self
        }
        ctx.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }


    /// 限制图片的宽高
    /// - Parameter maxWidth: 输出的图片的最大宽度，默认不限制
    /// - Parameter maxHeight: 输出图片的最大高度，默认不限制
    func limitImageSize(inWidth maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, maxHeight: CGFloat = CGFloat.greatestFiniteMagnitude) -> UIImage? {
        guard let image = fixedOrientation() else {
            return nil
        }
        if image.width < maxWidth, image.height < maxHeight { return self }
        var aspectScale: CGFloat = 0
        if image.width > maxWidth {
            aspectScale = maxWidth / image.width
        }
        if image.height > maxHeight {
            let heightScale = maxHeight / image.height
            aspectScale = max(aspectScale, heightScale)
        }
        let aspectWidth = image.width * aspectScale
        let aspectHeight = image.height * aspectScale
        UIGraphicsBeginImageContext(CGSize(width: aspectWidth, height: aspectHeight))
        draw(in: CGRect(x: 0, y: 0, width: aspectWidth, height: aspectHeight))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
}
