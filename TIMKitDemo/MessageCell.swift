//
//  MessageCellTableViewCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public class MessageCell: UITableViewCell {
    
    public var message: TIMMessage! {
        didSet {
            if let message = message {
                nicknameLabel.text = message.sender()
                roleLabel.text = message.isSelf() ? "主持人" : "特邀嘉宾"
            }
        }
    }
    
    public weak var avatarImageView: UIImageView!
    public weak var nicknameLabel: UILabel!
    public weak var roleLabel: UILabel!
    public weak var messageContentView: UIView!
    public weak var likeButton: UIButton!
    public weak var revokeButton: UIButton!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        let avatarWidth = CGFloat(44)
        let avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: "yingmu")
        avatarImageView.layer.cornerRadius = avatarWidth / CGFloat(2)
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.borderColor = UIColor.gray.cgColor
        avatarImageView.layer.masksToBounds = true
        contentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(16)
            make.top.equalTo(contentView).offset(16)
            make.size.equalTo(CGSize(width: avatarWidth, height: avatarWidth))
        }
        
        let nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.systemFont(ofSize: CGFloat(16))
        nicknameLabel.textColor = .black
        self.nicknameLabel = nicknameLabel
        contentView.addSubview(nicknameLabel)
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(16)
            make.top.equalTo(contentView).offset(8)
        }
        
        let roleLabel = UILabel()
        roleLabel.font = UIFont.systemFont(ofSize: CGFloat(12))
        roleLabel.textColor = .gray
        self.roleLabel = roleLabel
        contentView.addSubview(roleLabel)
        roleLabel.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel.snp.right).offset(8)
            make.lastBaseline.equalTo(nicknameLabel)
        }
        
        let messageContentView = UIView()
        self.messageContentView = messageContentView
        contentView.addSubview(messageContentView)
        let messageContentWidth = UIScreen.main.bounds.size.width * CGFloat(0.65) - 44 - 16 * 2
        messageContentView.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            make.width.equalTo(messageContentWidth)
            make.height.greaterThanOrEqualTo(44)
        }
//        messageContentView.backgroundColor = .systemGroupedBackground
        
        let likeButton = UIButton()
        likeButton.setTitleColor(.gray, for: .normal)
        likeButton.setTitle("喜欢100", for: .normal)
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.likeButton = likeButton
        contentView.addSubview(likeButton)
        likeButton.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel)
            make.top.equalTo(messageContentView.snp.bottom).offset(8)
        }
        
        let revokeButton = UIButton()
        self.revokeButton = revokeButton
        revokeButton.setTitle("撤回", for: .normal)
        revokeButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        revokeButton.setTitleColor(.gray, for: .normal)
        contentView.addSubview(revokeButton)
        revokeButton.snp.makeConstraints { make in
            make.top.equalTo(messageContentView.snp.bottom).offset(8)
            make.bottom.equalTo(contentView).offset(-16)
        }
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
