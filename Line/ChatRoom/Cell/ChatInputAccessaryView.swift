//
//  ChatInputAccessaryView.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatInputAccessaryView: UIView {

    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            sendButton.layer.cornerRadius = 15
            sendButton.imageView?.contentMode = .scaleAspectFill
            sendButton.contentVerticalAlignment = .fill
            sendButton.isEnabled = false
        }
    }

    @IBOutlet weak var chatTextView: UITextView! {
        didSet {
            chatTextView.layer.cornerRadius = 15
            chatTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
            chatTextView.layer.borderWidth = 1
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        nibInit()
        autoresizingMask = .flexibleHeight
    }

    override var intrinsicContentSize: CGSize {
        return .zero
    }

    private func nibInit() {
        let nib = UINib(nibName: "ChatInputAccessaryView", bundle: nil)

        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
