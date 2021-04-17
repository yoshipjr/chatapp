//
//  ChatRoomTableViewCell.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit
import Firebase
import Nuke

final class ChatRoomTableViewCell: UITableViewCell {

    var message: Message? {
        didSet {
            if let message = message {
                partnerMessageTextView.text = message.message
                let width = estimateFrameForTextView(text: message.message).width + 20
                partnerMessageTextViewConstraint.constant = width
                parnerDateLabel.text = dataFormatForDatelabel(date: message.createdAt.dateValue())
            }
        }
    }

    // MARK: properties
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 30
        }
    }
    

    @IBOutlet weak var partnerMessageTextView: UITextView! {
        didSet {
            partnerMessageTextView.layer.cornerRadius = 15
        }
    }

    @IBOutlet weak var myMessageTextView: UITextView! {
        didSet {
            myMessageTextView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var partnerMessageTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var myMessageTextvViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var parnerDateLabel: UILabel!
    @IBOutlet weak var myDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        checkWhichUserMessage()
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


    private func checkWhichUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        [partnerMessageTextView,
         parnerDateLabel,
         userImageView
        ].forEach { $0?.isHidden = (uid == message?.uid)
            ? true
            : false }

        [myMessageTextView,
         myDateLabel].forEach { $0?.isHidden = (uid == message?.uid)
            ? false
            : true }

        guard  let message = message else {
            return
        }
        let width = estimateFrameForTextView(text: message.message).width + 20
        if let urlString = message.partnerUser?.profileImageUrl, let url = URL(string: urlString) {
            Nuke.loadImage(with: url, into: userImageView)
        }
        if uid == message.uid {
            myMessageTextView.text = message.message
            myMessageTextvViewConstraint.constant = width
            myDateLabel.text = dataFormatForDatelabel(date: message.createdAt.dateValue())
        } else {
            partnerMessageTextView.text = message.message
            partnerMessageTextViewConstraint.constant = width
            parnerDateLabel.text = dataFormatForDatelabel(date: message.createdAt.dateValue())
        }

    }
}
