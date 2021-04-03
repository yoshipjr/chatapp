//
//  ChatRoomViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatRoomViewController: UIViewController {

    private let cellId = "cellId"

    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            chatRoomTableView.delegate = self
            chatRoomTableView.dataSource = self
            chatRoomTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.backgroundColor = .red
        return cell
    }
}
