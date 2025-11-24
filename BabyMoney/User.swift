//
//  User.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation
import SwiftData

@Model
final class User {
    var id: String
    var name: String
    var color: String
    var textColor: String
    var borderColor: String
    var iconColor: String
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
