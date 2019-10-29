//
//  VideoMessageCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/29.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import coswift
import CommonTools

public class VideoMessageCell: MessageCell {

    private weak var thumbnailView: UIImageView!
    private weak var playBtn: UIButton!
    private static var downloadTasks = [String: MessageFileDownloader]()

    public var videoContent: VideoMessageContent! {
        didSet {
            guard let objKey = videoContent.objectKey else {
                thumbnailView.image = UIImage()
                return
            }
            let thumbnailUrl = URL.imageURL(withName: objKey)
            if FileManager.default.fileExists(atPath: thumbnailUrl.path) {
                self.thumbnailView.sd_setImage(with: thumbnailUrl) { (image, error, cacheType, url) in

                }
                return
            }
            if VideoMessageCell.downloadTasks.keys.contains(objKey) {
                return
            }
            co_launch { [weak self] in
                guard let self = self else { return }
                let request = OSSDownloader.buildGetObjectRequest(bucketname: BucketName.image.rawValue, objectKey: objKey, targetFileURL: thumbnailUrl)
                let downloader = MessageFileDownloader(request: request, message: self.message)
                VideoMessageCell.downloadTasks[objKey] = downloader
                do {
                    let downloadResult = try await(promise: downloader.download())
                    switch downloadResult {
                    case .fulfilled(let _):
                        let tempContent = self.videoContent
                        self.videoContent = tempContent
                    case .rejected(let error):
                        Log.e("文件下载失败\(error)")
                    }
                } catch(let error) {
                    Log.e("文件下载失败\(error)")
                }
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
        self.thumbnailView = imgView
        imgView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imgView.makeCorner(radius: 8)
        imgView.backgroundColor = .randomColor()
        messageContentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            let width = UIScreen.main.width * 3 / 8
            make.width.equalTo(width)
            make.left.top.bottom.equalTo(messageContentView)
        }

        let playBtn = UIButton()
        self.playBtn = playBtn
        playBtn.setImage(UIImage(named: "play"), for: .normal)
        playBtn.setImage(UIImage(named: "stop"), for: .selected)
        messageContentView.addSubview(playBtn)
        playBtn.snp.makeConstraints { make in
            make.center.equalTo(imgView)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        revokeButton.snp.makeConstraints { make in
            make.right.equalTo(imgView)
        }
    }

}
