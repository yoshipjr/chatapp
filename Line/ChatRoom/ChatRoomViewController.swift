//
//  ChatRoomViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit
import Firebase

final class ChatRoomViewController: UIViewController {

    private let cellId = "cellId"
    private var messeages: [Message] = [Message]()
    var chatRoom: ChatRoom?
    var user: User?
    
    private lazy var chatInputAccessaryView: ChatInputAccessaryView = {
        let view = ChatInputAccessaryView()
        view.delegate = self
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        return view
    }()

    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            chatRoomTableView.delegate = self
            chatRoomTableView.dataSource = self
            chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
            chatRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 40, right: 0)
            chatRoomTableView.scrollIndicatorInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
            chatRoomTableView.keyboardDismissMode = .interactive
            chatRoomTableView.transform = .init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMessage()
    }

    override var inputAccessoryView: UIView? {
        return chatInputAccessaryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    private func fetchMessage() {
        guard let chatroomDocId = chatRoom?.documentId else { return }
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, error) in
            if let error = error {
                print("メッセージ情報の取得に失敗しました\(error)")
                return
            }
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                    case .added:
                        let dic = documentChange.document.data()
                        var message = Message(dic: dic)
                        message.partnerUser = self.chatRoom?.partnerUser
                        self.messeages.append(message)
                        self.messeages.sort { (m1, m2) -> Bool in
                            let m1Date = m1.createdAt.dateValue()
                            let m2Date = m2.createdAt.dateValue()
                            return m1Date > m2Date
                        }
                        self.chatRoomTableView.reloadData()
                        // ここで自動スクロールしてくれる
//                        self.chatRoomTableView.scrollToRow(at: IndexPath.init(row: self.messeages.count - 1 , section: 0), at: .bottom, animated: true)
                    case .modified:
                        break
                    case .removed:
                        break
                }
            })
        }
    }

}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messeages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        chatRoomTableView.transform = .init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        cell.message = messeages[indexPath.row]
        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
}

extension ChatRoomViewController: ChatInputAccessaryViewDelegate {
    func tappedSendButton(text: String) {
        guard
            let chatroomDocId = chatRoom?.documentId,
            let name = user?.userName,
            let uid = Auth.auth().currentUser?.uid else
        {
            return
        }
        let messageId = randomString(length: 20)

        let docData = [
            "name": name,
            "createdAt" : Timestamp(),
            "uid" : uid,
            "message" : text
        ] as [String : Any]

        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) { (error) in
            if let error = error {
                print("メッセージ情報の保存に失敗しました。\(error)")
                return
            }
        }

        let latestMessageData = [
            "latestMessageId" : messageId
        ]

        Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (error) in
            if let error = error {
                print("最新メッセージの保存に失敗しました\(error)")
                return
            }

        }
    }
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

}
