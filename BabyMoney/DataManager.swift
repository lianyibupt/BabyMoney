//
//  DataManager.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let DEFAULT_PIN = "0000"
    private let weeklyAllowanceKey = "weekly_allowance"
    
    // 简单的内存存储
    private var mockUsers: [User] = []
    private var mockTransactions: [Transaction] = []
    
    // 初始用户数据
    private let initialUsers: [User] = [
        User(id: "u1", name: "蓝莓", color: "#f3e8ff", textColor: "#9333ea", borderColor: "#e9d5ff", iconColor: "#9333ea", balance: 50),
        User(id: "u2", name: "樱桃", color: "#fce7f3", textColor: "#db2777", borderColor: "#fbcfe8", iconColor: "#db2777", balance: 50)
    ]
    
    private init() {
        // 初始化模拟数据
        initializeMockData()
    }
    
    // 初始化模拟数据
    private func initializeMockData() {
        mockUsers = initialUsers
        
        // 添加一些模拟交易数据
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        mockTransactions = [
            Transaction(id: "t1", userId: "u1", amount: 12.5, type: "out", categoryId: "food", date: "今天", rawDate: today, time: "14:30"),
            Transaction(id: "t2", userId: "u1", amount: 50.0, type: "in", categoryId: nil, date: "今天", rawDate: today, time: "12:00"),
            Transaction(id: "t3", userId: "u2", amount: 15.0, type: "out", categoryId: "book", date: "昨天", rawDate: "2023-11-23", time: "16:45")
        ]
    }
    
    // 获取所有用户
    func getAllUsers() -> [User] {
        return mockUsers
    }
    
    // 根据ID获取用户
    func getUserById(_ id: String) -> User? {
        return mockUsers.first { $0.id == id }
    }
    
    // 更新用户余额
    func updateUserBalance(userId: String, amount: Double, type: String) {
        if let index = mockUsers.firstIndex(where: { $0.id == userId }) {
            if type == "in" {
                mockUsers[index].balance += amount
            } else {
                mockUsers[index].balance -= amount
            }
        }
    }
    
    // 添加交易
    func addTransaction(_ transaction: Transaction) {
        mockTransactions.append(transaction)
    }
    
    // 获取用户交易记录
    func getTransactionsForUser(_ userId: String) -> [Transaction] {
        return mockTransactions.filter { $0.userId == userId }
    }
    
    // 添加新用户
    func addNewUser(name: String) -> User {
        let newUser = User(
            id: UUID().uuidString,
            name: name,
            color: "#fce7f3",
            textColor: "#db2777",
            borderColor: "#fbcfe8",
            iconColor: "#db2777",
            balance: 0
        )
        
        mockUsers.append(newUser)
        return newUser
    }
    
    // 删除用户
    func deleteUser(_ userToDelete: User) {
        mockUsers.removeAll { $0.id == userToDelete.id }
        mockTransactions.removeAll { $0.userId == userToDelete.id }
    }
    
    // 添加新交易
    func addTransaction(userId: String, amount: Double, type: String, categoryId: String? = nil) {
        // 创建新交易
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let rawDate = dateFormatter.string(from: now)
        
        dateFormatter.dateFormat = "MM月dd日"
        let formattedDate = dateFormatter.string(from: now)
        
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: now)
        
        let newTransaction = Transaction(
            id: UUID().uuidString,
            userId: userId,
            amount: amount,
            type: type,
            categoryId: categoryId,
            date: formattedDate,
            rawDate: rawDate,
            time: time
        )
        
        mockTransactions.append(newTransaction)
        
        // 更新用户余额
        updateUserBalance(userId: userId, amount: amount, type: type)
    }
    
    // 获取用户余额
    func getUserBalance(userId: String) -> Double {
        if let user = mockUsers.first(where: { $0.id == userId }) {
            return user.balance
        }
        return 0
    }
    
    // 获取消费类别统计
    func getCategoryStatistics(userId: String) -> [(category: Category, amount: Double, percentage: Double)] {
        // 获取用户的所有支出交易
        let expenseTransactions = mockTransactions.filter { 
            $0.userId == userId && $0.type == "out"
        }
        
        // 按类别ID分组并计算总金额
        var categoryTotals: [String: Double] = [:]
        var totalExpense = 0.0
        
        for transaction in expenseTransactions {
            if let categoryId = transaction.categoryId {
                categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + transaction.amount
                totalExpense += transaction.amount
            }
        }
        
        // 获取所有类别并关联金额
        var result: [(category: Category, amount: Double, percentage: Double)] = []
        let categories = Category.allCategories
        
        for category in categories {
            if let amount = categoryTotals[category.id] {
                let percentage = totalExpense > 0 ? (amount / totalExpense) * 100 : 0
                result.append((category: category, amount: amount, percentage: percentage))
            }
        }
        
        // 按金额降序排序
        return result.sorted { $0.amount > $1.amount }
    }
    
    // 验证PIN码
    func verifyPIN(_ pin: String) -> Bool {
        return pin == DEFAULT_PIN
    }
    
    // 获取每周零花钱
    func getWeeklyAllowance() -> Double {
        return UserDefaults.standard.double(forKey: weeklyAllowanceKey)
    }
    
    // 设置每周零花钱
    func setWeeklyAllowance(_ amount: Double) {
        UserDefaults.standard.set(amount, forKey: weeklyAllowanceKey)
    }
}

// 扩展Date以获取ISO8601格式的字符串
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension Formatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
