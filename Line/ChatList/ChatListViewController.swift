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
    private var chatRooms = [ChatRoom]()
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
        FirestoreManager.shared.fetchLoginUserInfo { (result) in
            switch result {
                case .success(let user):
                    self.user = user

                case .failure(_):
                    break
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Firestore.firestore().collection("chatRooms").getDocuments { (snapshots, err) in
            if let err = err {
                print("ChatRooms情報の取得に失敗しました。\(err)")
                return
            }

            snapshots?.documents.forEach({ (snapshot) in
                let dic = snapshot.data()
                var chatroom = ChatRoom(dic: dic)

                guard let uid = Auth.auth().currentUser?.uid else { return }
                chatroom.memebers.forEach { (memberUid) in
                    if memberUid != uid {
                        Firestore.firestore().collection("users").document(memberUid).getDocument { (snaoshot, err) in
                            if let err = err {
                                print("ユーザー情報の取得に失敗しました。\(err)")
                                return
                            }

                            guard let dic = snaoshot?.data() else { return }
                            var user = User(dic: dic)
                            user.uid = snapshot.documentID

                            chatroom.partnerUser = user
                            self.chatRooms.append(chatroom)
                            print("self.chatroooms.count: ", self.chatRooms.count)
                            self.chatListTableView.reloadData()
                        }
                    }
                }
            })
        }

    }

    @objc private func tappedChatButton() {
        let storyBoard = UIStoryboard.init(name: "UserListViewController", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
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
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//            }
//        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, error) in
//            if let error = error {
//                print("ユーザー情報の取得に失敗しました。\(error)")
//            }
//
//            guard
//                let snapshot = snapshot,
//                let data = snapshot.data() else
//            {
//                return
//            }
//
//            let user = User(dic: data)
//            self.user = user
//        }
        FirestoreManager.shared.fetchLoginUserInfo { (result) in
            switch result {
                case .success(let user):
                    self.user = user

                case .failure(_):
                    break
            }
        }
    }

}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatListTableViewCell

        cell.chatRoom = chatRooms[indexPath.row]

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
