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
    private var chatRoomListener: ListenerRegistration?

    @IBOutlet weak var chatListTableView: UITableView! {
        didSet {
            chatListTableView.delegate = self
            chatListTableView.dataSource = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirestoreManager.shared.fetchLoginUserInfo { (result) in
            switch result {
                case .success(let user):
                    self.user = user

                case .failure(_):
                    break
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        confirmLoggedInUser()
        fetchChatRoomsInfoFromFirestore()
    }

    func fetchChatRoomsInfoFromFirestore() {
        chatRoomListener?.remove()
        chatRooms.removeAll()
        chatListTableView.reloadData()

        chatRoomListener =  Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, err) in
                if let err = err {
                    print("ChatRooms情報の取得に失敗しました。\(err)")
                    return
                }
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                        case .added:
                            self.handleAddedDocumentChanged(documentChange)
                        case .modified:
                            break
                        case .removed:
                            break
                    }
                })
            }
    }

    private func handleAddedDocumentChanged(_ documentChange: DocumentChange ) {
        let dic = documentChange.document.data()
        var chatroom = ChatRoom(dic: dic)
        chatroom.documentId = documentChange.document.documentID

        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = chatroom.memebers.contains(uid)

        if !isContain { return }
        chatroom.memebers.forEach { (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument { (userSnapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        return
                    }

                    guard let dic = userSnapshot?.data()
                    else { return }

                    var user = User(dic: dic)
                    user.uid = documentChange.document.documentID
                    let latestMessageId = chatroom.latestMessageId
                    chatroom.partnerUser = user

                    if latestMessageId == "" {
                        self.chatRooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        return
                    }

                    Firestore.firestore().collection("chatRooms").document(chatroom.documentId ?? "" ).collection("messages").document(latestMessageId).getDocument { (messageSnapshot, error) in
                        if let error = error {
                            print("最新情報の取得に失敗しました\(error)")
                        }
                        guard let dic = messageSnapshot?.data() else { return }
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message
                        self.chatRooms.append(chatroom)
                        self.chatListTableView.reloadData()
                    }
                }
            }
        }
    }

    @objc private func tappedChatButton() {
        let storyBoard = UIStoryboard.init(name: "UserListViewController", bundle: nil)
        let vc = storyBoard.instantiateViewController(identifier: "UserListViewController")
        let nav = UINavigationController(rootViewController: vc)
        self.present(nav, animated: true)
    }

    @objc private func tappedLogoutButton() {
        do{
            try Auth.auth().signOut()
            pushViewController()
        } catch {
            print("ログアウトに失敗しました\(error)")
        }

    }

    private func confirmLoggedInUser() {
        if Auth.auth().currentUser?.uid == nil {
            pushViewController()
        }
    }

    private func pushViewController() {
        let stroyBoard = UIStoryboard(name: "SignUp", bundle: nil)
        let signUpViewController = stroyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController

        let nav = UINavigationController(rootViewController: signUpViewController)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }

    private func setupViews() {
        navigationController?.navigationBar.barTintColor = .rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [ .foregroundColor: UIColor.white]

        let rightButton = UIBarButtonItem(title: "新規チャット", style: .plain, target: self, action: #selector(tappedChatButton))
        let logoutButton = UIBarButtonItem(title: "ログアウト", style: .plain, target: self, action: #selector(tappedLogoutButton))

        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.tintColor = .white

        navigationItem.leftBarButtonItem = logoutButton
        navigationItem.leftBarButtonItem?.tintColor = .white
    }

    private func fetchLoginUserInfo() {
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
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        vc.chatRoom = chatRooms[indexPath.row]
        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }
}
