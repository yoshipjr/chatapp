//
//  Data+Extension.swift
//  Line
//
//  Created by 北原義久 on 2021/04/11.
//

import Foundation

extension Date {
    var dateFormatterForDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}
