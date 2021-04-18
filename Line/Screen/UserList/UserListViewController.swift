//
//  UserListViewController.swift
//  Line
//
//  Created by 北原義久 on 2021/04/10.
//

import UIKit

final class UserListViewController: UIViewController {

    private let cellId = "cellId"
    private var selectedUser: User?
    private var datasource: UserListTableViewDatasource = UserListTableViewDatasource()

    @IBOutlet weak var userListTableView: UITableView! {
        didSet {
            userListTableView.delegate = self
            userListTableView.dataSource = datasource
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
        FirestoreManager.shared.fetchUserInfoFromFirestore { (result) in
            switch result {
                case .success(let user):
                    self.datasource.users.append(user)
                    self.userListTableView.reloadData()
                case .failure(let error):
                    self.showSimpleAlert(title: "user情報の取得に失敗", message: error.localizedDescription)
            }
        }
    }
}

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = datasource.users[indexPath.row]
        self.selectedUser = user
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
