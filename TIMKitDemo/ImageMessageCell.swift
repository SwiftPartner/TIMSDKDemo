//
//  ImageMessageCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/28.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SnapKit
import CommonTools
import SDWebImage
import RxSwift
import coswift

public class ImageMessageCell: MessageCell {

    private weak var imgView: UIImageView!
    private static var downloadTasks = [String: MessageFileDownloader]()

    public var imageContent: ImageMessageContent! {
        didSet {
            if let objectKey = imageContent.objectKey {
                let url = URL.imageURL(withName: objectKey)
                Log.i("地址路径:\(url)")
                if FileManager.default.fileExists(atPath: url.path) {
                    imgView.sd_setImage(with: url) { (image, error, cacheType, url) in
                        Log.i("图片加载完成\(image) \(error)")
                    }
                    return
                }
                imageView?.image = UIImage()
                guard let _ = ImageMessageCell.downloadTasks[objectKey] else {
                    let request = OSSDownloader.buildGetObjectRequest(bucketname: BucketName.image.rawValue, objectKey: objectKey, targetFileURL: url)
                    let downloader = MessageFileDownloader(request: request, message: message)
                    ImageMessageCell.downloadTasks[objectKey] = downloader
                    co_launch { [weak self] in
                        do {
                            let result = try await(promise: downloader.download())
                            switch result {
                            case .fulfilled(let res):
                                ImageMessageCell.downloadTasks[objectKey] = nil
                                let content = self?.imageContent
                                self?.imageContent = content
                                Log.i("文件下载成功……")
                            case .rejected(let error):
                                ImageMessageCell.downloadTasks[objectKey] = nil
                                if objectKey == self?.imageContent.objectKey {
                                    self?.imageView?.image = UIImage()
                                }
                                Log.i("文件下载失败……\(error)")
                            }

                        } catch(let error) {
                            Log.e("文件下载失败\(error)")
                        }
                    }
                    Log.i("下载图片……")
                    return
                }
                Log.i("下载任务已在队列中")
            } else {
                imgView.image = UIImage()
            }
        }
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        let imgView = UIImageView()
        imgView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imgView.backgroundColor = .white
        self.imgView = imgView
        messageContentView.addSubview(imgView)
        imgView.makeCorner(radius: 8)
        imgView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(messageContentView)
            let width = UIScreen.main.width / 2 - 100
            make.width.equalTo(width)
        }
        revokeButton.snp.makeConstraints { make in
            make.right.equalTo(imgView)
        }
    }



}
