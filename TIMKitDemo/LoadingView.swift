//
//  LoadingView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

public class LoadingView: UIView {
    
    private weak var indicatorView: UIActivityIndicatorView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("not implemented...")
    }
    
    private func setup() {
        let indicatorView = UIActivityIndicatorView()
        self.indicatorView = indicatorView
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
    }
}
