//
//  BaseViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import SnapKit
import CommonTools

public class BaseViewController: UIViewController {

    private weak var loadingView: LoadingView!

    public var showLoadingView = false {
        didSet {
            if showLoadingView {
                if loadingView == nil {
                    let loadingView = LoadingView()
                    self.loadingView = loadingView
                    view.addSubview(loadingView)
                    loadingView.snp.makeConstraints { make in
                        make.edges.equalTo(view)
                    }
                }
                view.bringSubviewToFront(loadingView)
            } else {
                loadingView.removeFromSuperview()
                loadingView = nil
            }
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if showLoadingView, let loadingView = self.loadingView {
            view.bringSubviewToFront(loadingView)
        }
    }
}
