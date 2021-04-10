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
            profileButton.isEnabled = false
            profileButton.addTarget(self, action: #selector(tappedProfileButton), for: .touchUpInside)
        }
    }

    @IBOutlet weak var emailTextFiled: UITextField! {
        didSet {
            emailTextFiled.delegate = self
        }
    }


    @IBOutlet weak var passwordTextFiled: UITextField! {
        didSet {
            passwordTextFiled.delegate = self
        }
    }

    @IBOutlet weak var usernameTextFiled: UITextField! {
        didSet {
            usernameTextFiled.delegate = self
        }
    }

    @IBOutlet weak var registerButton: UIButton! {
        didSet {
            registerButton.layer.cornerRadius = 15
        }
    }

    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc private func tappedProfileButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }

        profileButton.setTitle("", for: .normal)
        profileButton.imageView?.contentMode = .scaleAspectFill
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill
        profileButton.clipsToBounds = true

        dismiss(animated: true)
    }
}

extension SignUpViewController: UITextFieldDelegate {

    func textFieldDidChangeSelection(_ textField: UITextField) {
        let isEmailEmpty = emailTextFiled.text?.isEmpty ?? false
        let isPaswordEmpty = passwordTextFiled.text?.isEmpty ?? false
        let isUsernameEmpty = usernameTextFiled.text?.isEmpty ?? false
        if isEmailEmpty || isPaswordEmpty || isUsernameEmpty {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 0, green: 100, blue: 100)
        }
    }
}
