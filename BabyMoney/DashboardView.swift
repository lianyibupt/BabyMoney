//
//  DashboardView.swift
//  BabyMoney
//
//  Created by 易炼 on 2025/11/24.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    let user: User
    @State private var transactions: [Transaction] = []
    @State private var showReports = false
    @State private var showTransactionHistory = false
    @State private var showSettings = false
    @State private var showAIAdvice = false
    @State private var showAddTransaction = false
    @State private var selectedTransactionType: TransactionType = .income
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 顶部用户信息和余额卡片
                    VStack {
                        // 返回按钮和设置按钮
                        HStack {
                            Button(action: {
                                // 返回用户选择界面
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.backward")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showSettings.toggle()
                            }) {
                                Image(systemName: "gear")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        // 用户信息和余额
                        VStack(spacing: 8) {
                            HStack {
                                ZStack {
                                    Color(hex: user.color)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                    
                                    Image(systemName: "rabbit.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color(hex: user.iconColor))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("嗨，\(user.name)！")
                                        .font(.system(size: 24, weight: .bold))
                                    Text("今天是个理财的好日子！")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 16)
                            }
                            .padding(.top, 24)
                            
                            // 余额卡片
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [Color(hex: user.color), Color(hex: user.color).opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                                    .cornerRadius(24)
                                    .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                VStack(spacing: 8) {
                                    Text("我的零花钱")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color(hex: user.textColor))
                                    
                                    Text("¥\(user.balance, specifier: "%.2f")")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(Color(hex: user.textColor))
                                }
                                .padding(32)
                            }
                            .padding(.top, 24)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // 功能按钮区域
                    HStack(spacing: 20) {
                        // 存款按钮
                        Button(action: {
                            // 存款功能
                            showAddTransaction = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Color.green.opacity(0.1)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                    
                                    Image(systemName: "arrow.down.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.green)
                                }
                                
                                Text("存入")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        
                        // 取款按钮
                        Button(action: {
                            // 取款功能
                            showAddTransaction = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Color.red.opacity(0.1)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                    
                                    Image(systemName: "arrow.up.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.red)
                                }
                                
                                Text("取出")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        
                        // 历史按钮
                        Button(action: {
                            // 历史功能
                            showTransactionHistory = true
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Color.purple.opacity(0.1)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                    
                                    Image(systemName: "clock.arrow.circlepath")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.purple)
                                }
                                
                                Text("历史")
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                        
                        // 设置按钮
                Button(action: {
                    showSettings = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Color.blue.opacity(0.1)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            
                            Image(systemName: "gear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                        
                        Text("设置")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                // 报告按钮
                Button(action: {
                    showReports = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Color.green.opacity(0.1)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            
                            Image(systemName: "chart.bar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.green)
                        }
                        
                        Text("报告")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                
                // 智慧兔兔按钮
                Button(action: {
                    showAIAdvice = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Color.purple.opacity(0.1)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            
                            Image(systemName: "brain.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                        }
                        
                        Text("智慧兔兔")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                    .padding(.horizontal, 24)
                    
                    // 近期交易记录
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("近期交易")
                                .font(.system(size: 24, weight: .bold))
                            
                            Spacer()
                            
                            Button(action: {
                                // 查看全部交易
                            }) {
                                Text("查看全部")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // 交易列表
                        if transactions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "receipt.long")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("暂无交易记录")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(40)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(20)
                        } else {
                            ForEach(transactions, id: \.id) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
            .background(Color.white)
            .navigationBarHidden(true)
        }
        .onAppear {
            loadTransactions()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("TransactionsUpdated"))) {
            _ in
            loadTransactions()
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView(user: user)
        }
        .sheet(isPresented: $showTransactionHistory) {
                    TransactionHistoryView(user: user)
                        .environment(\.modelContext, modelContext)
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .environment(\.modelContext, modelContext)
                }
                .sheet(isPresented: $showAIAdvice) {
                    AIAdviceView(user: user)
                        .environment(\.modelContext, modelContext)
                }
                .sheet(isPresented: $showReports) {
                    ReportsView(user: user)
                        .environment(\.modelContext, modelContext)
                }
    }
    
    private func loadTransactions() {
        // 加载近期交易记录
        transactions = DataManager.shared.getTransactions(for: user.id, limit: 5)
    }
}

// 交易行组件
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // 分类图标
            if let category = Category.getCategoryById(transaction.categoryId) {
                ZStack {
                    Color(hex: category.backgroundColor)
                        .frame(width: 60, height: 60)
                        .cornerRadius(16)
                    
                    Image(systemName: category.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(hex: category.color))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(Category.getCategoryById(transaction.categoryId)?.name ?? "未分类")
                    .font(.system(size: 18, weight: .medium))
                
                Text("\(transaction.date) \(transaction.time)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 16)
            
            Spacer()
            
            Text(transaction.type == .income ? "+¥\(transaction.amount, specifier: "%.2f")" : "-¥\(transaction.amount, specifier: "%.2f")")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// 添加交易视图
struct AddTransactionView: View {
    let user: User
    @State private var amount: String = ""
    @State private var type: TransactionType = .expense
    @State private var selectedCategoryId: String = Category.allCategories.first?.id ?? ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 类型选择器
                Picker("交易类型", selection: $type) {
                    Text("存入").tag(TransactionType.income)
                    Text("取出").tag(TransactionType.expense)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // 金额输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("金额")
                        .font(.system(size: 18, weight: .medium))
                    
                    TextField("请输入金额", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 36, weight: .bold))
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                
                // 分类选择 (仅在取出时显示)
                if type == .expense {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("分类")
                            .font(.system(size: 18, weight: .medium))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Category.allCategories, id: \.id) { category in
                                    Button(action: {
                                        selectedCategoryId = category.id
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Color(hex: category.backgroundColor)
                                                    .frame(width: 80, height: 80)
                                                    .cornerRadius(16)
                                                    .opacity(selectedCategoryId == category.id ? 1 : 0.5)
                                                
                                                Image(systemName: category.iconName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .foregroundColor(Color(hex: category.color))
                                            }
                                            
                                            Text(category.name)
                                                .font(.system(size: 14))
                                                .foregroundColor(selectedCategoryId == category.id ? .black : .gray)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    // 存款时使用默认分类
                    selectedCategoryId = Category.allCategories.first?.id ?? ""
                }
                
                Spacer()
                
                // 确认按钮
                Button(action: {
                    if let amountValue = Double(amount), amountValue > 0 {
                        let success = DataManager.shared.handleTransaction(
                            type: type,
                            userId: user.id,
                            amount: amountValue,
                            categoryId: selectedCategoryId
                        )
                        
                        if success {
                            // 发送通知，通知DashboardView刷新数据
                            NotificationCenter.default.post(name: Notification.Name("TransactionsUpdated"), object: nil)
                            // 也通知用户数据已更新
                            NotificationCenter.default.post(name: Notification.Name("UserDataUpdated"), object: nil)
                            dismiss()
                        } else {
                            // 显示错误消息
                            alertMessage = type == .expense ? "余额不足，请检查余额后再试" : "交易失败，请重试"
                            showAlert = true
                        }
                    } else {
                        alertMessage = "请输入有效的金额"
                        showAlert = true
                    }
                }) {
                    Text("确认")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(24)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(type == .income ? "存款" : "取款"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("确定"))
                    )
                }
            }
            .navigationTitle(type == .income ? "存入零花钱" : "取出零花钱")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("取消") { dismiss() })
        }
    }
}

#Preview {
    let user = User(id: "1", name: "小明", color: "FF9500", textColor: "FFFFFF", borderColor: "FFCC00", iconColor: "FFFFFF", balance: 100.0)
    return DashboardView(user: user)
}

// 导入UIKit用于导航控制器
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}