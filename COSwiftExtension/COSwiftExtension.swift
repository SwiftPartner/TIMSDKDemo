//
//  Haha.swift
//  COSwiftExtension
//
//  Created by ryan on 2019/10/21.
//  Copyright © 2019 windbird. All rights reserved.
//

import UIKit
import coswift

public extension UIAlertController {
    
    func cose_present(from viewController: UIViewController, cancelTitle: String?, confirmTitle: String?) -> Promise<String?> {
        let promise = Promise<String?>()
        let handler: ((UIAlertAction) -> Void) = {action in
            promise.fulfill(value: action.title)
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: handler)
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default, handler: handler)
        addAction(cancelAction)
        addAction(confirmAction)
        return promise
    }
    
}
