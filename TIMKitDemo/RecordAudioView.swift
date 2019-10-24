
//
//  RecordView.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/24.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
public class RecordAudioView: UIView {

    private(set) public weak var timeLabel: UILabel!
    private(set) public weak var recordButton: AudioRecordButton!
    private(set) public weak var recordContainer: UIView!
    private(set) public weak var auditionView: AuditionView!

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
            make.size.equalTo(CGSize(width: 60, height: 60))
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

    public func showRecord() {
        auditionView.isHidden = true
        recordContainer.isHidden = false
    }

    public func showAudition() {
        auditionView.isHidden = false
        recordContainer.isHidden = true
    }
}


extension RecordAudioView: AudioRecordButtonDelegate {

    public func onStartRecord(recordButton: AudioRecordButton) {

    }

    public func onStopRecord(recordButton: AudioRecordButton) {
        showAudition()
    }
}

extension RecordAudioView: AuditionViewDelegate {

    public func onClickPlayBtn(_ sender: UIButton, of auditionView: AuditionView) {

    }

    public func onClickDeleteBtn(_ sender: UIButton, of auditionView: AuditionView) {
        showRecord()
    }

    public func onClickSendBtn(_ sender: UIButton, of auditionView: AuditionView) {
        showRecord()
    }
}
