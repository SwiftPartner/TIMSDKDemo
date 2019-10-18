//
//  AudioRecordButton.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

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
            backgroundColor = isRecording ? .red : .green
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
        backgroundColor = .green
        self.recordMode = recordMode
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        makeCorner(radius: width / 2, borderColor: .yellow, borderWidth: 3)
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
