//
//  ChatListViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class ChatListViewController: UIViewController {

    private let cellId: String = "cellId"
    private var user: User? {
        didSet {
            navigationItem.title = user?.userName
        }
    }

    @IBOutlet weak var chatListTableView: UITableView! {
        didSet {
            chatListTableView.delegate = self
            chatListTableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        confirmLoggedInUser()
        fetchLoginUserInfo()
    }

    @objc private func tappedChatButton() {
        let storyBoard = UIStoryboard.init(name: "UserListViewController", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }

    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            let stroyBoard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = stroyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true)
        }
    }

    private func setupViews() {
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor: UIColor.white]

        let rightButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedChatButton))

        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }

    private func fetchLoginUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
            }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("ユーザー情報の取得に失敗しました。\(error)")
            }

            guard
                let snapshot = snapshot,
                let data = snapshot.data() else
            {
                return
            }

            let user = User(dic: data)
            self.user = user
        }
    }

}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
