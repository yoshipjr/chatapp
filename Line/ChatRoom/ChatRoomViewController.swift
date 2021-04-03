//
//  ChatRoomViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatRoomViewController: UIViewController {

    private let cellId = "cellId"
    private var chatInputAccessaryView: ChatInputAccessaryView = {
        let view = ChatInputAccessaryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        return view
    }()

    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            chatRoomTableView.delegate = self
            chatRoomTableView.dataSource = self
//            chatRoomTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
            chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
            chatRoomTableView.backgroundColor = .rgb(red: 118, green: 140, blue: 180)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override var inputAccessoryView: UIView? {
        return chatInputAccessaryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
}
