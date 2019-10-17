//
//  EasyColor.swift
//  TIMKitDemo
//
//  Created by ryan on 2019/10/16.
//  Copyright © 2019 windbird. All rights reserved.
//

import Foundation

extension UIColor {
    
    public static var groupColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGroupedBackground
        } else {
            return .groupTableViewBackground
        }
    }()
    
}
