//
//  ChatListTableViewCell.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit
import Nuke

class ChatListTableViewCell: UITableViewCell {

    var chatRoom: ChatRoom? {
        didSet {
            partnerLabel.text = chatRoom?.partnerUser?.userName
            guard let url = URL(string: chatRoom?.partnerUser?.profileImageUrl ?? "") else { return }
            Nuke.loadImage(with: url, into: userImageView)

            dataLabel.text = chatRoom?.latestMessage?.createdAt.dateValue().dateFormatterForDateLabel
            latestMessageLabel.text = chatRoom?.latestMessage?.message
        }
    }


    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 35
        }
    }
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func dataFormatForDatelabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_jp")
        return formatter.string(from: date)
    }
}
