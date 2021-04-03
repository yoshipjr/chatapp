//
//  SignUpViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class SignUpViewController: UIViewController {

    @IBOutlet weak var profileButton: UIButton! {
        didSet {
            profileButton.layer.cornerRadius = 85
            profileButton.layer.borderWidth = 1
            profileButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
        }
    }

    @IBOutlet weak var emailTextFiled: UITextField!

    @IBOutlet weak var passwordTextFiled: UITextField!

    @IBOutlet weak var usernameTextFiled: UITextField!

    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.layer.cornerRadius = 15
        }
    }

    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
