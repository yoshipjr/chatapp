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
    private var users: [User] = [User]()

    @IBOutlet weak var chatListTableView: UITableView! {
        didSet {
            chatListTableView.delegate = self
            chatListTableView.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor: UIColor.white]

        if Auth.auth().currentUser?.uid == nil {
            let stroyBoard = UIStoryboard(name: "SignUp", bundle: nil)
            let signUpViewController = stroyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.modalPresentationStyle = .fullScreen
            self.present(signUpViewController, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserInfoFromFirestore()
    }

    private func fetchUserInfoFromFirestore() {
        Firestore.firestore().collection("users").getDocuments { (snapshot, error) in
            if let error = error {
                print("user情報の取得に失敗しました。\(error)")

            }
            snapshot?.documents.forEach({ (snapshot) in
                let data = snapshot.data()
                let user: User = User(dic: data)

                self.users.append(user)
                self.chatListTableView.reloadData()

                self.users.forEach { (user) in
                    print("user:", user.userName)
                }
            })

        }
    }

}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell
        cell.user = users[indexPath.row]

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
