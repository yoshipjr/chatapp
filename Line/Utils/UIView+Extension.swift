//
//  UIView+Extension.swift
//  Line
//
//  Created by 北原義久 on 2021/04/17.
//

import UIKit


extension UIViewController {

    enum Handler {
        case success
        case failure
    }

    func showSimpleAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
        })
        let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
            print("「いいえ」が選択されました！")
        })
        alert.addAction(noAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true)
    }
}
