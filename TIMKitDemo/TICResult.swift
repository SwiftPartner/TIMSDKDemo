//
//  TICResult.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/15.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
public class TICResult: CustomStringConvertible {
    public var code: Int32
    public var desc: String
    public var isSuccess: Bool {
        return code == 0
    }
    public init(code: Int32, desc: String?) {
        self.code = code
        self.desc = desc ?? ""
    }
    
    public var description: String {
        return "code: \(code), desc: \(desc)"
    }

}
