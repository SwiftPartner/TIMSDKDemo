//
//  MessageElement.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/17.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol MessageElement {
    var suffix: String {get}
    var json:JSON {get}
}
