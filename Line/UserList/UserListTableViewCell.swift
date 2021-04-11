//
//  UserListTableViewCell.swift
//  Line
//
//  Created by 北原義久 on 2021/04/11.
//

import UIKit
import Nuke

final class UserListTableViewCell: UITableViewCell {

    var user: User? {
        didSet {
            partnerName.text = user?.userName
            if let url = URL(string: user?.profileImageUrl ?? "") {
                Nuke.loadImage(with: url, into: profileImageView)
            }
        }
    }

    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            profileImageView.layer.cornerRadius = 25
        }
    }

    @IBOutlet weak var partnerName: UILabel!

    override class func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
