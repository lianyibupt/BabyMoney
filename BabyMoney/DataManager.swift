//
//  DataManager.swift
//  BabyMoney
//
//  Created by Developer on 2023/11/24.
//

import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    private let DEFAULT_PIN = "0000"
    private let weeklyAllowanceKey = "weekly_allowance"
    
    // SwiftData容器
    var container: ModelContainer?
    var context: ModelContext?
    
    // 初始用户数据
    private let initialUsers: [User] = [
        User(id: "u1", name: "姐姐", color: "#fce7f3", textColor: "#db2777", borderColor: "#fbcfe8", iconColor: "#db2777", balance: 50),
        User(id: "u2", name: "妹妹", color: "#f3e8ff", textColor: "#9333ea", borderColor: "#e9d5ff", iconColor: "#9333ea", balance: 50)
    ]
    
    private init() {
        setupSwiftData()
    }
    
    // 初始化默认数据
    func initializeDefaultData(modelContext: ModelContext) {
        // 查询是否已有用户数据
        let fetchDescriptor = FetchDescriptor<User>()
        do {
            let users = try modelContext.fetch(fetchDescriptor)
            if users.isEmpty {
                // 创建默认用户
                let defaultUsers = [
                    User(id: "1", name: "小明", color: "FF9500", textColor: "FFFFFF", borderColor: "FFCC00", iconColor: "FFFFFF", balance: 100.0),
                    User(id: "2", name: "小红", color: "FF6B6B", textColor: "FFFFFF", borderColor: "FF4757", iconColor: "FFFFFF", balance: 150.0),
                    User(id: "3", name: "小华", color: "4ECDC4", textColor: "FFFFFF", borderColor: "26C6DA", iconColor: "FFFFFF", balance: 80.0)
                ]
                
                // 添加到模型上下文
                for user in defaultUsers {
                    modelContext.insert(user)
                }
                
                // 保存
                try modelContext.save()
                print("默认用户数据已初始化")
            }
        } catch {
            print("初始化默认数据失败: \(error)")
        }
    }
    
    private func setupSwiftData() {
        do {
            let schema = Schema([User.self, Transaction.self])
            let modelConfiguration = ModelConfiguration(schema: schema)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            context = container?.mainContext
            
            // 检查是否需要初始化数据
            if let context = context {
                let fetchDescriptor = FetchDescriptor<User>()
                let users = try context.fetch(fetchDescriptor)
                if users.isEmpty {
                    // 添加初始用户
                    for user in initialUsers {
                        context.insert(user)
                    }
                    try context.save()
                }
            }
        } catch {
            print("SwiftData setup error: \(error)")
        }
    }
    
    // 获取所有用户
    func getAllUsers() -> [User] {
        guard let context = context else { return [] }
        do {
            let fetchDescriptor = FetchDescriptor<User>()
            return try context.fetch(fetchDescriptor)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    // 获取用户的交易记录，可选择按类型筛选
    func getTransactions(for userId: String, type: TransactionType? = nil) -> [Transaction] {
        guard let context = context else { return [] }
        do {
            // 构建基础谓词
            var predicates: [Predicate<Transaction>] = []
            predicates.append(#Predicate { $0.userId == userId })
            
            // 如果指定了类型，则添加类型筛选
            if let transactionType = type {
                predicates.append(#Predicate { $0.type == transactionType })
            }
            
            // 组合谓词
            let combinedPredicate = predicates.reduce(#Predicate { true }, { $0 && $1 })
            
            let fetchDescriptor = FetchDescriptor<Transaction>(predicate: combinedPredicate)
            fetchDescriptor.sortDescriptors = [SortDescriptor(\.rawDate, order: .reverse)]
            
            let transactions = try context.fetch(fetchDescriptor)
            print("获取交易记录成功，数量: \(transactions.count)")
            return transactions
        } catch {
            print("获取交易记录失败: \(error.localizedDescription)")
            return []
        }
    }
    
    // 处理交易（存款或取款）
    func handleTransaction(type: TransactionType, userId: String, amount: Double, categoryId: String) -> Bool {
        guard let context = context else { return false }
        
        // 查找用户
        guard let user = getUserById(userId) else {
            print("用户不存在")
            return false
        }
        
        // 检查余额是否足够（仅对支出交易）
        if type == .expense && user.balance < amount {
            print("余额不足")
            return false
        }
        
        // 创建交易记录
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: date)
        
        let transaction = Transaction(
            id: UUID().uuidString,
            userId: userId,
            amount: amount,
            type: type,
            categoryId: categoryId,
            date: dateString,
            rawDate: date,
            time: timeString
        )
        
        context.insert(transaction)
        
        // 更新用户余额
        if type == .income {
            user.balance += amount
        } else {
            user.balance -= amount
        }
        
        do {
            try context.save()
            print("交易添加成功")
            return true
        } catch {
            print("保存交易失败: \(error)")
            return false
        }
    }
    
    // 根据ID获取用户
    func getUserById(_ id: String) -> User? {
        guard let context = context else { return nil }
        do {
            let fetchDescriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == id })
            let users = try context.fetch(fetchDescriptor)
            return users.first
        } catch {
            print("Error fetching user by id: \(error)")
            return nil
        }
    }
    
    // 验证家长密码
    func authenticateWithPIN(_ pin: String) -> Bool {
        return pin == DEFAULT_PIN
    }
    
    // 获取周薪设置
    func getWeeklyAllowance() -> Double {
        return UserDefaults.standard.double(forKey: weeklyAllowanceKey) > 0 ? 
            UserDefaults.standard.double(forKey: weeklyAllowanceKey) : 20
    }
    
    // 设置周薪
    func setWeeklyAllowance(_ amount: Double) {
        UserDefaults.standard.set(amount, forKey: weeklyAllowanceKey)
    }
    
    // 重置用户账户
    func resetUserAccount(_ userId: String) -> Bool {
        guard let context = context else { return false }
        
        // 更新用户余额
        guard let user = getUserById(userId) else { return false }
        user.balance = 0
        
        // 删除该用户的所有交易记录
        do {
            let fetchDescriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.userId == userId })
            let transactions = try context.fetch(fetchDescriptor)
            for transaction in transactions {
                context.delete(transaction)
            }
            
            try context.save()
            return true
        } catch {
            print("Error resetting user account: \(error)")
            return false
        }
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
