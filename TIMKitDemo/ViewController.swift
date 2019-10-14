//
//  ViewController.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/12.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var recorder: AudioRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let param = TIMLoginParam()
        let userId = "kakaxi"
        param.identifier = userId
        param.userSig = GenerateTestUserSig.genTestUserSig(userId)
        TIMManager.sharedInstance()?.login(param, succ: { [weak self] in
            Log.i("登录成功……")
            self?.addRecordButton()
        }, fail: { (code, msg) in
            Log.e("登录失败……")
        })
        // Do any additional setup after loading the view.
    }
    
    func addRecordButton() {
        let recordButton = AudioRecordButton()
        recordButton.setup(recordMode: .touchToRecord)
        view.addSubview(recordButton)
        recordButton.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        recordButton.onStart = {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                   let voiceDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("voice")
                   let recorder = AudioRecorder(voiceDirectory: voiceDir)
                   do {
                       try recorder.record()
                       self.recorder = recorder
                   } catch(let error)  {
                       Log.e("因为录制失败\(error)")
            }
        }
        recordButton.onStop = {[weak self] in
            if let isRecording = self?.recorder?.isRecording, isRecording {
                self?.recorder?.stop()
                return
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
       
    }
}

