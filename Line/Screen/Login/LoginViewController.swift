//
//  LoginViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/17.
//

import UIKit
import Firebase

final class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 8
            loginButton.addTarget(self, action: #selector(didLoginButtonTapped), for: .touchUpInside)
        }
    }
    @IBOutlet weak var dontHaveAccountButton: UIButton! {
        didSet {
            dontHaveAccountButton.addTarget(self, action: #selector(didDontHaveAccountButtonTapped), for: .touchUpInside)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc private func didDontHaveAccountButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func didLoginButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else
        {
            return
        }
        HUDManager.shared.show()
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                HUDManager.shared.hide()
                self.showSimpleAlert(title: "ログインに失敗", message: error.localizedDescription)
                return
            }
            HUDManager.shared.hide()
            print("ログインに成功しました")
            let nav = self.presentingViewController as! UINavigationController
            let chatlistViewController = nav.viewControllers[nav.viewControllers.count - 1] as? ChatListViewController
            chatlistViewController?.fetchChatRoomsInfoFromFirestore()
            self.dismiss(animated: true)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
