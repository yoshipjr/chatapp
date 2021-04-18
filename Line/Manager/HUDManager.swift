//
//  HUDManager.swift
//  Line
//
//  Created by 北原義久 on 2021/04/17.
//

import PKHUD

final class HUDManager {

    static let shared = HUDManager()
    private init() {}

    func show() {
        HUD.show(.progress)
    }

    func hide() {
        HUD.hide()
    }
}
