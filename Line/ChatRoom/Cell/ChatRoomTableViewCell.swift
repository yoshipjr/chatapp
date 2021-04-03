//
//  ChatRoomTableViewCell.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatRoomTableViewCell: UITableViewCell {

    // MARK: properties
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 30
        }
    }
    
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.layer.cornerRadius = 10
        }
    }

    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
