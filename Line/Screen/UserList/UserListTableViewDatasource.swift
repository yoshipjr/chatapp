//
//  ChatListTableViewDatasource.swift
//  Line
//
//  Created by 北原義久 on 2021/04/11.
//

import UIKit

class UserListTableViewDatasource: NSObject, UITableViewDataSource {

    private let cellId = "cellId"
    var users = [User]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
}


