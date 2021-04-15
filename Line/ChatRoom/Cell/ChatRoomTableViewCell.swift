//
//  ChatRoomTableViewCell.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatRoomTableViewCell: UITableViewCell {

    var message: Message? {
        didSet {
            if let message = message {
                messageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                messageTextViewConstraint.constant = width
                dateLabel.text = dataFormatForDatelabel(date: message.createdAt.dateValue()
            }
        }
    }

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

    @IBOutlet weak var messageTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    private func estimateFrameForTextView(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)

        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }

    private func dataFormatForDatelabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_jp")
        return formatter.string(from: date)
    }
}
