//
//  Transaction.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case income = "in"
    case expense = "out"
}

@Model
final class Transaction {
    var id: String
    var userId: String
    var amount: Double
    var type: String // "in" or "out"
    var categoryId: String?
    var date: String
    var rawDate: String
    var time: String
    
    init(id: String, userId: String, amount: Double, type: String, categoryId: String? = nil, date: String, rawDate: String, time: String) {
        self.id = id
        self.userId = userId
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.date = date
        self.rawDate = rawDate
        self.time = time
    }
}
