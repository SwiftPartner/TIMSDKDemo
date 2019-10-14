//
//  AudioRecordButton.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/14.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

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
    public var onStart: (() -> Void)?
    public var onStop: (() -> Void)?
    
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
        layer.masksToBounds = true
        layer.borderWidth = 3
        layer.borderColor = UIColor.yellow.cgColor
        layer.cornerRadius = bounds.size.width / 2
    }
    
    @objc private func touchDown() {
        Log.i("按下……")
        if recordMode == .tapToRecord {
            return
        }
        onStart?()
        isRecording = true
    }
    
    @objc private func touchUpInside() {
        Log.i("抬起……")
        if recordMode == .tapToRecord, !isRecording {
            onStart?()
            isRecording = true
            return
        }
        onStop?()
        isRecording = false
    }
}
