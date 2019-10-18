//
//  AuditionView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

@objc public protocol AuditionViewDelegate {
    @objc optional func onClickDeleteBtn( _ sender: UIButton, of auditionView: AuditionView);
    @objc optional func onClickPlayBtn(_ sender: UIButton, of auditionView: AuditionView );
    @objc optional func onClickSendBtn(_ sender: UIButton, of auditionView: AuditionView);
}

public class AuditionView: UIView {
  
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    public weak var delegate: AuditionViewDelegate?
    public var isPlaying: Bool = false {
        didSet {
            if let playButton = playButton {
                playButton.isSelected = isPlaying
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubview()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubview()
    }
    
    private func setupSubview() {
        let contentNib = UINib(nibName: "AuditionView", bundle: nil)
        let contentView = contentNib.instantiate(withOwner: self, options: nil).first as! UIView
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        contentView.backgroundColor = .white
        let cornerRadius = playButton.width / 2
        playButton.makeCorner(radius: cornerRadius, borderColor: .link, borderWidth: 4)
    }
    
    public override func layoutSubviews() {
        
    }
    
    
    
    @IBAction func onClickDelete(_ sender: UIButton) {
        delegate?.onClickDeleteBtn?(sender, of: self)
    }
    
    @IBAction func onClickPlay(_ sender: UIButton) {
        delegate?.onClickPlayBtn?(sender, of: self)
    }
    
    @IBAction func onClickSend(_ sender: UIButton) {
        delegate?.onClickSendBtn?(sender, of: self)
    }
}
