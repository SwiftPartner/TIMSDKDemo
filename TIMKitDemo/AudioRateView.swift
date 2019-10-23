//
//  AudioRateView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/23.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SnapKit

@objc public protocol AudioRateViewDelegate {
    @objc optional func audioRateView(_ rateView: AudioRateView, didSelectRate rate: Float)
}

public class AudioRateView: UIView {

    private static let rates: [Float] = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2]
    private weak var rateButton: UIButton!
    private weak var stackView: UIStackView!
    private var rightMargin: Constraint!
    public weak var delegate: AudioRateViewDelegate?

    public var rate: Float = 1 {
        didSet { rateButton.setTitle("\(rate)x", for: .normal) }
    }

    public var showRates: Bool = false {
        didSet {
            stackView.arrangedSubviews.forEach { view in
                let index = stackView.arrangedSubviews.firstIndex(of: view)
                UIView.animate(withDuration: 0.02 * Double(index!), animations: { [weak self] in
                    if let self = self {
                        view.isHidden = !self.showRates
                        self.rightMargin.update(offset: self.showRates ? 8 : 0)
                    }
                })
            }
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

    @objc private func toggleRateButtons(_ button: UIButton) {
        showRates = !showRates
    }

    @objc private func didSelectRateButton(_ button: UIButton) {
        let rate = Float(button.tag) / 100.0
        self.rate = rate
        delegate?.audioRateView?(self, didSelectRate: rate)
        showRates = false
    }

    private func setupSubviews() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        addSubview(effectView)
        effectView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let rateButton = UIButton()
        rateButton.addTarget(self, action: #selector(toggleRateButtons(_:)), for: .touchUpInside)
        rateButton.backgroundColor = .red
        rateButton.makeCorner(radius: 22)
        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rateButton.setTitle("1.0x", for: .normal)
        self.rateButton = rateButton
        addSubview(rateButton)
        rateButton.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.top.bottom.equalTo(self)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        let buttons = AudioRateView.rates.map { rate -> UIButton in
            let button = UIButton(type: .system)
            button.tag = Int(rate * 100.0)
            button.addTarget(self, action: #selector(didSelectRateButton(_:)), for: .touchUpInside)
            button.isHidden = true
            button.setTitle("\(rate)", for: .normal)
            return button
        }
        let stackView = UIStackView(arrangedSubviews: buttons)
        self.stackView = stackView
        stackView.axis = .horizontal
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerY.equalTo(rateButton)
            make.right.equalTo(rateButton.snp.left)
            rightMargin = make.left.equalTo(self).offset(0).constraint
        }
    }

}
