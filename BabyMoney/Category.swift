//
//  Category.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation

struct Category {
    let id: String
    let name: String
    let iconName: String
    let color: String
    let backgroundColor: String
    let chartColor: String
    
    init(id: String, name: String, iconName: String, color: String, backgroundColor: String, chartColor: String) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.color = color
        self.backgroundColor = backgroundColor
        self.chartColor = chartColor
    }
}

// 预定义的消费类别数组
extension Category {
    static let allCategories: [Category] = [
        Category(id: "toy", name: "玩具", iconName: "gamecontroller", color: "#3b82f6", backgroundColor: "#dbeafe", chartColor: "#3b82f6"),
        Category(id: "food", name: "零食", iconName: "fork.knife", color: "#f97316", backgroundColor: "#ffedd5", chartColor: "#f97316"),
        Category(id: "clothes", name: "衣服", iconName: "tshirt", color: "#a855f7", backgroundColor: "#f3e8ff", chartColor: "#a855f7"),
        Category(id: "book", name: "书本", iconName: "book", color: "#22c55e", backgroundColor: "#dcfce7", chartColor: "#22c55e"),
        Category(id: "other", name: "其他", iconName: "package", color: "#9ca3af", backgroundColor: "#f3f4f6", chartColor: "#9ca3af")
    ]
    
    static func getCategoryById(_ id: String) -> Category? {
        return allCategories.first { $0.id == id }
    }
}
