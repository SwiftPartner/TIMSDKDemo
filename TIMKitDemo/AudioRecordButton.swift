//
//  AudioRecordButton.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import CommonTools

@objc public protocol AudioRecordButtonDelegate {
    @objc optional func onStartRecord(recordButton: AudioRecordButton);
    @objc optional func onStopRecord(recordButton: AudioRecordButton);
}

public class AudioRecordButton: UIButton {
    
    public enum RecordMode: Int {
        case touchToRecord, tapToRecord
    }
    
    public lazy var recordMode: RecordMode = .touchToRecord
    private var isRecording = false {
        didSet {
            backgroundColor = isRecording ? UIColor.hexColor(hex: 0xD92846) : UIColor.hexColor(hex: 0x1CB827)
        }
    }
    public weak var delegate: AudioRecordButtonDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public func setup(recordMode: RecordMode) {
        backgroundColor = UIColor.hexColor(hex: 0x1CB827)
        self.recordMode = recordMode
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        makeCorner(radius: width / 2, borderColor: .white, borderWidth: 5)
    }
    
    @objc private func touchDown() {
        Log.i("按下……")
        if recordMode == .tapToRecord {
            return
        }
        delegate?.onStartRecord?(recordButton: self)
        isRecording = true
    }
    
    @objc private func touchUpInside() {
        Log.i("抬起……")
        if recordMode == .tapToRecord, !isRecording {
            delegate?.onStartRecord?(recordButton: self)
            isRecording = true
            return
        }
        delegate?.onStopRecord?(recordButton: self)
        isRecording = false
    }
    
    public func stopRecord() {
        isRecording = false
    }
}
