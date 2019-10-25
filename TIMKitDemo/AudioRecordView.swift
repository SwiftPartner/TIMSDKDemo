
//
//  RecordView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/24.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

public protocol AudioRecordViewDelegate {
    func onStartRecord(from recordView: AudioRecordView)
    func onStopRecord(from recordView: AudioRecordView)
    func onPlayAudition(from recordView: AudioRecordView)
    func onDelete(from recordView: AudioRecordView)
    func onSend(from recordView: AudioRecordView)
}

public class AudioRecordView: UIView {

    private(set) public weak var timeLabel: UILabel!
    private(set) public weak var recordButton: AudioRecordButton!
    private(set) public weak var recordContainer: UIView!
    private(set) public weak var auditionView: AuditionView!
    public var delegate: AudioRecordViewDelegate?
    public var isPlayingAudition: Bool = false {
        didSet {
            auditionView.isPlaying = isPlayingAudition
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
        let container = UIStackView()
        self.recordContainer = container
        container.axis = .vertical
        container.spacing = 5
        addSubview(container)
        container.snp.makeConstraints { make in
            make.center.equalTo(self)
        }

        let timeLabel = UILabel()
        timeLabel.textAlignment = .center
//        timeLabel.isHidden = true
        timeLabel.text = "0/\(180)"
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        container.addArrangedSubview(timeLabel)
        self.timeLabel = timeLabel

        let recordButton = AudioRecordButton()
        recordButton.delegate = self
        self.recordButton = recordButton
        recordButton.setup(recordMode: .tapToRecord)
        container.addArrangedSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 80, height: 80))
        }

        let auditionView = AuditionView()
        auditionView.delegate = self
        auditionView.isHidden = true
        self.auditionView = auditionView
        addSubview(auditionView)
        auditionView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }

    /// 泗安事
    public func showAudition() {
        auditionView.isHidden = false
        recordContainer.isHidden = true
    }

    /// 显示、隐藏录音按钮
    public func showRecord() {
        auditionView.isHidden = true
        recordContainer.isHidden = false
    }


}

// MARK: AudioRecordButton相关的操作方法
extension AudioRecordView {

    public func stopRecord() {
        recordButton.stopRecord()
        showAudition()
    }
}

extension AudioRecordView: AudioRecordButtonDelegate {

    public func onStartRecord(recordButton: AudioRecordButton) {
        delegate?.onStartRecord(from: self)
    }

    public func onStopRecord(recordButton: AudioRecordButton) {
        showAudition()
        delegate?.onStopRecord(from: self)
    }
}

extension AudioRecordView: AuditionViewDelegate {

    public func onClickPlayBtn(_ sender: UIButton, of auditionView: AuditionView) {
        delegate?.onPlayAudition(from: self)
    }

    public func onClickDeleteBtn(_ sender: UIButton, of auditionView: AuditionView) {
        showRecord()
        delegate?.onDelete(from: self)
    }

    public func onClickSendBtn(_ sender: UIButton, of auditionView: AuditionView) {
        showRecord()
        delegate?.onSend(from: self)
    }
}
