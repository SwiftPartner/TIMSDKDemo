//
//  TextMessageCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/15.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class TextMessageCell: MessageCell {
    
    private weak var contentLabel: UILabel!
    
    public override var message: TIMMessage! {
        didSet {
            super.message = message
            if let message = message, let textElem = message.getElem(0) as? TIMTextElem {
                contentLabel.text = textElem.text
            }
        }
    }
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
    }
    
    func setupSubviews() {
        let contentLabelContainer = UIView()
        contentLabelContainer.layer.cornerRadius = 8
        contentLabelContainer.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            contentLabelContainer.backgroundColor = .systemGroupedBackground
        } else {
            contentLabelContainer.backgroundColor = .groupTableViewBackground
        }
        let contentLabel = UILabel()
        contentLabel.numberOfLines = 0
        self.contentLabel = contentLabel
        contentLabelContainer.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.left.equalTo(contentLabelContainer).offset(8)
            make.bottom.right.equalTo(contentLabelContainer).offset(-8)
        }
        messageContentView.addSubview(contentLabelContainer)
        contentLabelContainer.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(messageContentView)
            make.right.lessThanOrEqualTo(messageContentView)
            make.width.greaterThanOrEqualTo(80)
        }
        revokeButton.snp.makeConstraints { make in
            make.right.equalTo(contentLabelContainer)
        }
    }
    
}
