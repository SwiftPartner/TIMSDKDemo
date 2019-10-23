//
//  CoursewareView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/23.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import CommonTools

@objc public protocol CoursewareViewDelegate {

    @objc func coursewareView(_ coursewareView: CoursewareView, didScrollToPage page: Int)
}

public class CoursewareView: UIView {

    private static let pptCellID = "pptCell"
    private(set) public weak var collectionView: UICollectionView?
    private lazy var images = ["ppt1", "ppt2", "ppt3", "ppt4", "ppt5"]
    private weak var delegate: CoursewareViewDelegate?
    private(set) public var currentPage = 0
    public var totalPage: Int { return images.count }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }

    private func setupSubviews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: width, height: height)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.register(CoursewareCell.self, forCellWithReuseIdentifier: CoursewareView.pptCellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
        self.collectionView = collectionView
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}

extension CoursewareView: UICollectionViewDataSource, UICollectionViewDelegate {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CoursewareView.pptCellID, for: indexPath) as! CoursewareCell
        let imgName = images[indexPath.item]
        let imgPath = Bundle.main.path(forResource: imgName, ofType: "png")
        cell.image = UIImage(contentsOfFile: imgPath!)
        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / width)
        currentPage = page
        delegate?.coursewareView(self, didScrollToPage: page)
        Log.i("滚动到了第\(page)页")
    }

    public func scrollTo(page: Int) {
        if page < images.count {
            collectionView?.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: false)
        }
    }
}
