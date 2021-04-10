//
//  UserListViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/10.
//

import UIKit

final class UserListViewController: UIViewController {

    private let cellId = "cellIde"
    @IBOutlet weak var userListTableView: UITableView! {
        didSet {
            userListTableView.delegate = self
            userListTableView.dataSource = self
            userListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}


extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        return cell
    }


}
