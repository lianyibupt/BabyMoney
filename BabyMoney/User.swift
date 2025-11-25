//
//  User.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation

// 用户结构体，不使用SwiftData
struct User {
    let id: String
    let name: String
    let color: String
    let textColor: String
    let borderColor: String
    let iconColor: String
    var balance: Double
    
    init(id: String, name: String, color: String, textColor: String, borderColor: String, iconColor: String, balance: Double) {
        self.id = id
        self.name = name
        self.color = color
        self.textColor = textColor
        self.borderColor = borderColor
        self.iconColor = iconColor
        self.balance = balance
    }
}
