//
//  MoreCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/25.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public class MoreMenuCell: UICollectionViewCell {

    private weak var iconView: UIImageView!
    private weak var titleLabel: UILabel!
    public var moreMenu: MoreMenu! {
        didSet {
            iconView.image = moreMenu?.icon
            titleLabel.text = moreMenu?.title
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        let stackView = UIStackView()
        stackView.spacing = 5
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalTo(contentView)
        }
        let iconView = UIImageView()
        iconView.contentMode = .center
        iconView.backgroundColor = .white
        iconView.makeCorner(radius: 10)
        stackView.addArrangedSubview(iconView)
        self.iconView = iconView
        iconView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.hexColor(hex: 0x333333)
        titleLabel.textAlignment = .center
        stackView.addArrangedSubview(titleLabel)
        self.titleLabel = titleLabel
    }
}
