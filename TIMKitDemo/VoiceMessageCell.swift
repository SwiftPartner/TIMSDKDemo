//
//  VoiceMessageCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/15.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SnapKit

public class VoiceMessageCell: MessageCell {
    
    private weak var playButton: UIButton!
    private var palyButtonWidth: SnapKit.Constraint!
    public override var message: TIMMessage! {
        didSet {
            super.message = message
        }
    }
    
    public var voiceContent: VoiceMessageContent! {
        didSet {
            playButton.setTitle("\(voiceContent.second)秒", for: .normal)
        }
    }
    
    public var voiceWidth: CGFloat = 100 {
        didSet{
            if let palyButtonWidth = palyButtonWidth {
                let voiceWidth = self.voiceWidth
                palyButtonWidth.update(offset: voiceWidth)
//                layoutIfNeeded()
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
        let playButton = UIButton()
        playButton.contentHorizontalAlignment = .left
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.circle"), for: .selected)
        playButton.backgroundColor = bubbleColor
        playButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        playButton.setTitle("100s", for: .normal)
        playButton.setTitleColor(.link, for: .normal)
        playButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        self.playButton = playButton
        messageContentView.addSubview(playButton)
        playButton.makeCorner(radius: 8)
        playButton.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(messageContentView)
//            make.height.equalTo(44)
            palyButtonWidth = make.width.greaterThanOrEqualTo(100).constraint
        }
        revokeButton.snp.makeConstraints { make in
            make.right.equalTo(playButton)
        }
    }
    
}
