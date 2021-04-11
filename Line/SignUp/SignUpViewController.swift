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
        guard  let image = profileButton.imageView?.image,
               let uploadImage = image.jpegData(compressionQuality: 0.3)  else {
            return
        }
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_image").child(fileName)
        storageRef.putData(uploadImage, metadata: nil) { metadata, error in
            if let error = error {
                print("画像のストレージの保存に失敗しました。\(error)")
                let alert = UIAlertController(title: "画像のストレージ保存に失敗", message: "画像のストレージ保存に失敗しました", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "はい", style: .default, handler: { (UIAlertAction) in
                    print("「はい」が選択されました！")
                })
                let noAction = UIAlertAction(title: "いいえ", style: .default, handler: { (UIAlertAction) in
                    print("「いいえ」が選択されました！")
                })
                alert.addAction(noAction)
                alert.addAction(yesAction)
                self.present(alert, animated: true)

                return
            }
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("firestorageからのダウンロードに失敗しました。\(error)")
                    let arert = UIAlertController(title: "ダウンロードに失敗しました", message: "画像のダウンロードに失敗", preferredStyle: .alert)
                    self.present(arert, animated: true)
                    return
                }
                guard let urlString = url?.absoluteString else {
                    return
                }

                self.createUserToFirestore(url: urlString)
            }

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

    private func createUserToFirestore(url: String) {
        guard let email = emailTextFiled.text,
              let password = passwordTextFiled.text,
              let userName = usernameTextFiled.text else
        {
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { (response, err) in
            if let err =  err {
                print("auth情報の保存に失敗しました:", err)
            }


            let docdata: [String : Any] = [
                "email" : email,
                "username" : userName,
                "imageUrl" : url,
                "createdAt" : Timestamp()
            ]

            guard let uid = response?.user.uid else { return }
            Firestore.firestore().collection("users").document(uid).setData(docdata) { (err) in
                if let err = err {
                    print("データベースへの保存に失敗しました。", err)
                    return
                }
                print("データベースへの保存に成功しました")
                self.dismiss(animated: true)
            }
        }
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
