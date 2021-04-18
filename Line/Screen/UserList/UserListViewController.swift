//
//  UserListViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/10.
//

import UIKit
import Firebase
import FirebaseFirestore

final class UserListViewController: UIViewController {

    private let cellId = "cellId"
    private var users = [User]()
    private var selectedUser: User?

    @IBOutlet weak var userListTableView: UITableView! {
        didSet {
            userListTableView.delegate = self
            userListTableView.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftButton = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(tappedBackButton))
        leftButton.tintColor = .white

        let rightButton = UIBarButtonItem(title: "チャット開始", style: .plain, target: self, action: #selector(tappedChatStartButton))
        rightButton.tintColor = .white
        rightButton.isEnabled = false

        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 69, blue: 49)
        fetchUserInfoFromFirestore()
    }

    @objc private func tappedBackButton() {
        self.dismiss(animated: true)
    }

    @objc private func tappedChatStartButton() {
        guard
               let partnerUid = selectedUser?.uid  else
        {
            return
        }
        FirestoreManager.shared.startChat(selectedUserID: partnerUid) { (result) in
            switch result {
                case .success:
                    self.dismiss(animated: true)
                    break
                case .failure(let error):
                    self.showSimpleAlert(title: "チャットルーム情報の保存に失敗しました", message: error.localizedDescription)
                    break
            }
        }
    }

    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("user情報の取得に失敗しました。\(error)")

            }
            snapshot?.documents.forEach({ (snapshot) in
                let data = snapshot.data()
                var user: User = User(dic: data)

                user.uid = snapshot.documentID

                guard let uid = Auth.auth().currentUser?.uid else { return }

                if uid == snapshot.documentID {
                    return
                }

                self.users.append(user)
                self.userListTableView.reloadData()

                self.users.forEach { (user) in
                    print("user:", user.userName)
                }
            })

        }
    }
}


extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        self.selectedUser = user
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
