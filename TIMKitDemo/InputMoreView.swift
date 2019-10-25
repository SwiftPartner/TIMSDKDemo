//
//  MessageInputMenuView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public protocol InputMoreViewDelegate {
    func moreView(_ moreView: InputMoreView, didSelectMenu menu: MoreMenu)
}

public class InputMoreView: UIView {

    private static let menuCellId = "menu_cell_id"
    private(set) public weak var collectionView: UICollectionView!
    private(set) public lazy var flowLayout = UICollectionViewFlowLayout()
    public var delegate: InputMoreViewDelegate?
    public lazy var menus: [MoreMenu] = {
        let imageMenu = MoreMenu(icon: UIImage(named: "image")!, title: "图片", type: .image)
        let videoMenu = MoreMenu(icon: UIImage(named: "video")!, title: "视频", type: .video)
        let coursewareMenu = MoreMenu(icon: UIImage(named: "document")!, title: "课件", type: .courseware)
        return [imageMenu, videoMenu, coursewareMenu]
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews () {
        flowLayout.itemSize = CGSize(width: 80, height: 80)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(MoreMenuCell.self, forCellWithReuseIdentifier: InputMoreView.menuCellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = .zero
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
//            make.edges.equalTo(self)
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 80 * 3 + 10 * 2, height: 80))
        }
    }

    public func relayoutCollectionView() {

    }
}

extension InputMoreView: UICollectionViewDataSource, UICollectionViewDelegate {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuCell = collectionView.dequeueReusableCell(withReuseIdentifier: InputMoreView.menuCellId, for: indexPath) as! MoreMenuCell
        menuCell.moreMenu = menus[indexPath.item]
        return menuCell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menu = menus[indexPath.item]
        delegate?.moreView(self, didSelectMenu: menu)
    }

}
