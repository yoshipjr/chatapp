//
//  User.swift
//  Line
//
//  Created by 北原義久 on 2021/04/10.
//

import Foundation
import Firebase

struct User {
    let email: String
    let userName: String
    let createdAt: Timestamp
    let profileImageUrl: String

    var uid: String?

    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.userName = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["imageUrl"] as? String ?? ""
    }
}
