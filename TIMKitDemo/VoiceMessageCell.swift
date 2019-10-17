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
    
    public var voiceWidth: CGFloat = 100 {
        didSet{
            if let palyButtonWidth = palyButtonWidth {
                let voiceWidth = self.voiceWidth
                UIView.animate(withDuration: 0.1) { [weak self] in
                    palyButtonWidth.update(offset: voiceWidth)
                    self?.layoutIfNeeded()
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
        let playButton = UIButton()
        playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        playButton.setImage(UIImage(systemName: "pause.circle"), for: .selected)
        messageContentView.addSubview(playButton)
        playButton.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(messageContentView)
            palyButtonWidth = make.width.equalTo(100).constraint
        }
    }
    
}
