//
//  CoursewareCell.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/23.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public class CoursewareCell: UICollectionViewCell {

    private weak var pictureView: UIImageView?
    public var image: UIImage? {
        didSet {
            pictureView?.image = image
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
        let pictureView = UIImageView()
        pictureView.contentMode = .scaleAspectFill
        pictureView.clipsToBounds = true
        self.pictureView = pictureView
        addSubview(pictureView)
        pictureView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
