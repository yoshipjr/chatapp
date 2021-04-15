//
//  Message.swift
//  Line
//
//  Created by 北原義久 on 2021/04/15.
//

import Foundation
import Firebase

struct Message {

    let name: String
    let message: String
    let uid: String
    let createdAt: Timestamp

    init(dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.message = dic["message"] as? String ?? ""
        self.uid = dic["uid"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
