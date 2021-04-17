//
//  SignUpViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

final class SignUpViewController: UIViewController {

    @IBOutlet weak var profileButton: UIButton! {
        didSet {
            profileButton.layer.cornerRadius = 85
            profileButton.layer.borderWidth = 1
            profileButton.layer.borderColor = UIColor.rgb(red: 240, green: 240, blue: 240).cgColor
            profileButton.isEnabled = true
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

    @IBAction func tappedRegisterButton(_ sender: Any) {
        let image = profileButton.imageView?.image ?? UIImage(named: "fiji")
        guard let uploadImage = image?.jpegData(compressionQuality: 0.3)  else {
            return
        }
        HUDManager.shared.show()
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { metadata, error in
            if let error = error {
                HUDManager.shared.hide()
                self.showSimpleAlert(title: "画像のストレージ保存に失敗", message: error.localizedDescription)
                return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("firestorageからのダウンロードに失敗しました。\(error)")
                    let arert = UIAlertController(title: "ダウンロードに失敗しました", message: "画像のダウンロードに失敗", preferredStyle: .alert)
                    self.present(arert, animated: true)
                    HUDManager.shared.hide()
                    return
                }
                guard let urlString = url?.absoluteString else {
                    return
                }

                guard let email = self.emailTextFiled.text, let pasword = self.passwordTextFiled.text, let username = self.usernameTextFiled.text else { return }

                FirestoreManager.shared.createUserToFirestore(email: email, password: pasword, userName: username, url: urlString) {
                    HUDManager.shared.hide()
                    self.dismiss(animated: true)
                }
            }

        }
    }

    @IBOutlet weak var alreadyHaveAccountButton: UIButton! {
        didSet {
            alreadyHaveAccountButton.addTarget(self, action: #selector(didAlreadyHaveAccountButtonTapped), for: .touchUpInside)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc private func tappedProfileButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true)
    }

    @objc private func didAlreadyHaveAccountButtonTapped() {
        let storyboard = UIStoryboard.init(name: "LoginViewController", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        navigationController?.pushViewController(loginViewController, animated: true)
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
            registerButton.isEnabled = false
            registerButton.backgroundColor = .rgb(red: 100, green: 100, blue: 100)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = .rgb(red: 0, green: 100, blue: 100)
        }
    }
}
