//
//  Pathes.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
public extension URL {
    
    static let voiceDirectory: URL = {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let voiceDir = paths[0].appendingPathComponent("com_xdpaction_actionpi").appendingPathComponent("voice")
        return voiceDir
    }()
    
}
