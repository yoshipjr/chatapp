//
//  ChatInputAccessaryView.swift
//  Line
//
//  Created by 北原義久 on 2021/04/03.
//

import UIKit

final class ChatInputAccessaryView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        nibInit()
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
