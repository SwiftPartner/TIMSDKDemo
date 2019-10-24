//
//  MessageInputMenuView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
public class MessageInputMenuView: UIView {

    private static let menuCellId = "menu_cell_id"
    private weak var collectionView: UICollectionView?
    private(set) public lazy var flowLayout = UICollectionViewFlowLayout()

    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupSubviews () {
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = .zero
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

extension MessageInputMenuView: UICollectionViewDataSource, UICollectionViewDelegate {

   public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

   public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageInputMenuView.menuCellId, for: indexPath)
        cell.backgroundColor = .randomColor
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }

}
