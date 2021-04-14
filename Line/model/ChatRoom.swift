//
//  ChatRoom.swift
//  Line
//
//  Created by 北原義久 on 2021/04/11.
//

import Foundation
import FirebaseFirestore

struct ChatRoom {
    let latestMessageId: String
    let memebers: [String]
    let createdAt: Timestamp

    var partnerUser: User?

    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.memebers = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic["creagedAt"] as? Timestamp ?? Timestamp()
    }
}
