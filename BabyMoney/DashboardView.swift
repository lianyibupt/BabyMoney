import SwiftUI

struct DashboardView: View {
    @AppStorage("currentUserName") var userName: String = "蓝莓"
    @State private var balance: Double = 0.0
    @State private var thisMonthIncome: Double = 0.0
    @State private var thisMonthExpense: Double = 0.0
    @State private var showAddTransaction = false
    @State private var activeTab = 0
    @State private var showSettings = false
    @State private var refreshTrigger = false
    @State private var showTransactionList = false
    @State private var showTransactionDetail = false
    @State private var selectedTransaction: Transaction?
    @State private var recentTransactions: [Transaction] = []
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5") // 浅粉色背景
                .ignoresSafeArea()
            
            ZStack(alignment: .bottom) {
                // Content
                ZStack {
                // 根据活动标签显示不同内容
                switch activeTab {
                case 0:
                    // 主页内容
                    VStack {
                        // 顶部用户信息
                        HStack {
                            VStack(alignment: .leading) {
                                Text("欢迎，\(userName)")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        HStack {
                            Text("余额")
                                .font(.system(size: 18))
                                .foregroundColor(Color.gray)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        // 余额显示 - 放大字体
                        Text("￥\(String(format: "%.2f", balance))")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(Color.black)
                            .padding(.horizontal, 20)
                        
                        Spacer().frame(height: 20)
                        
                        // 账户卡片 (Modified to show income/expense with larger fonts)
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hex: userName == "蓝莓" ? "9B6BFF" : "FF6B6B"))
                                .padding(.horizontal, 20)
                                .shadow(radius: 5)
                            
                            HStack(spacing: 20) {
                                // 收入
                                VStack {
                                    Text("本月收入")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text(String(format: "+¥%.2f", thisMonthIncome))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color.white)
                                }
                                
                                Spacer()
                                
                                // 支出
                                VStack {
                                    Text("本月支出")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.white.opacity(0.8))
                                    Text(String(format: "-¥%.2f", thisMonthExpense))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color.white)
                                }
                            }
                            .padding(22)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        // 最近交易标题
                        HStack {
                            Text("最近交易")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.black)
                            
                            Spacer()
                            
                            Button(action: {
                                showTransactionList = true
                            }) {
                                Text("查看全部")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "FF8585"))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // 交易列表
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(recentTransactions.prefix(5), id: \.id) { transaction in
                                    TransactionRowView(transaction: transaction)
                                        .onTapGesture {
                                            selectedTransaction = transaction
                                            showTransactionDetail = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 72)
                        }
                        
                        // 记一笔按钮
                        Button(action: {
                            showAddTransaction.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FF8585"))
                                    .frame(width: 60, height: 60)
                                    .shadow(radius: 5)
                                
                                Text("+")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color.white)
                            }
                        }
                        .padding(.bottom, 72)
                    }
                case 1:
                    // 报告页面
                    ReportsViewContent(userName: userName)
                case 2:
                    // 建议页面
                    AIAdviceViewContent()
                case 3:
                    // 我的页面 - 显示设置
                    SettingsView()
                default:
                    Text("未知页面")
                }
                
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 底部导航栏
                HStack(spacing: 0) {
                    TabButton(index: 0, icon: "house", title: "主页", isActive: $activeTab)
                    TabButton(index: 1, icon: "chart.pie", title: "报告", isActive: $activeTab)
                    TabButton(index: 2, icon: "brain", title: "建议", isActive: $activeTab)
                    TabButton(index: 3, icon: "person", title: "我的", isActive: $activeTab)
                }
                .padding(.top, 5)
                .padding(.bottom, 5)
                .background(Color.white)
                .cornerRadius(16, corners: [.topLeft, .topRight])
                .shadow(radius: 6, y: -3)
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView {
                refreshData()
            }
        }
        .sheet(isPresented: $showTransactionList) {
            TransactionListView()
        }
        .sheet(isPresented: $showTransactionDetail) {
            if let transaction = selectedTransaction {
                TransactionDetailView(transaction: transaction) {
                    deleteTransaction(transaction)
                }
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: userName) { _, newValue in
            refreshData()
        }
        .onChange(of: refreshTrigger) { _, _ in
            refreshData()
        }
    }
    
    private func refreshData() {
        let users = DataManager.shared.getAllUsers()
        if let currentUser = users.first(where: { $0.name == userName }) {
            balance = currentUser.balance
            
            // 加载交易数据
            recentTransactions = DataManager.shared.getTransactionsForUser(currentUser.id)
        }
        
        // 计算本月收入和支出
        let transactions = recentTransactions
        
        thisMonthIncome = transactions
            .filter { $0.type == "in" }
            .reduce(0) { $0 + $1.amount }
        
        thisMonthExpense = transactions
            .filter { $0.type == "out" }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        // 从本地列表中移除
        recentTransactions.removeAll { $0.id == transaction.id }
        // 刷新数据
        refreshData()
    }
}

struct TransactionItem: Identifiable {
    let id = UUID()
    let name: String
    let type: TransactionType
    let amount: String
    let date: String
    let icon: String
    
    enum TransactionType {
        case income, expense
    }
}

struct TransactionRow: View {
    let transaction: TransactionItem
    
    var body: some View {
        HStack {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2)
                
                Text(transaction.icon)
                    .font(.system(size: 24))
            }
            
            Spacer().frame(width: 15)
            
            // 交易信息
            VStack(alignment: .leading) {
                Text(transaction.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
                
                Text(transaction.date)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            // 金额
            Text(transaction.amount)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(transaction.type == .income ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct TabButton: View {
    let index: Int
    let icon: String
    let title: String
    @Binding var isActive: Int
    
    var body: some View {
        Button(action: {
            isActive = index
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isActive == index ? Color(hex: "FF8585") : Color.gray)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isActive == index ? Color(hex: "FF8585") : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct AddTransactionView: View {
    @AppStorage("currentUserName") var userName: String = "蓝莓"
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedType: String = "out" // "in" or "out"
    @State private var selectedCategory: String? = nil
    @Environment(\.dismiss) var dismiss
    var onTransactionAdded: () -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF8585"))
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("记一笔")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 20)
                
                // 可滚动内容
                ScrollView {
                    VStack(spacing: 20) {
                        // 金额输入
                        VStack(spacing: 10) {
                            Text("金额")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            // 金额输入 - 放大字体
                        TextField("输入金额", text: $amount)
                            .font(.system(size: 64, weight: .bold))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 3)
                        }
                        .padding(.horizontal, 30)
                        
                        // 类型选择
                        VStack(spacing: 10) {
                            Text("类型")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 20) {
                                TypeButton(
                                    title: "收入",
                                    color: Color(hex: "4CAF50"),
                                    isSelected: selectedType == "in"
                                ) {
                                    selectedType = "in"
                                    selectedCategory = nil // 收入不需要分类
                                }
                                TypeButton(
                                    title: "支出",
                                    color: Color(hex: "FF6B6B"),
                                    isSelected: selectedType == "out"
                                ) {
                                    selectedType = "out"
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        // 分类选择（仅支出时显示）
                        if selectedType == "out" {
                            VStack(spacing: 10) {
                                Text("分类")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(Category.allCategories, id: \.id) { category in
                                            CategoryButton(
                                                category: category,
                                                isSelected: selectedCategory == category.id
                                            ) {
                                                selectedCategory = category.id
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                        
                        // 描述输入
                        VStack(spacing: 10) {
                            Text("描述")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("添加描述（可选）", text: $description)
                                .font(.system(size: 16))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(radius: 3)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                }
                
                // 确认按钮 - 固定在底部
                Button(action: saveTransaction) {
                    Text("确认")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FF8585"))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                .padding(.top, 10)
            }
        }
    }
    
    private func saveTransaction() {
        // 验证金额
        guard let amountValue = Double(amount), amountValue > 0 else {
            return
        }
        
        // 获取用户ID
        let users = DataManager.shared.getAllUsers()
        guard let user = users.first(where: { $0.name == userName }) else {
            return
        }
        
        // 保存交易
        DataManager.shared.addTransaction(
            userId: user.id,
            amount: amountValue,
            type: selectedType,
            categoryId: selectedCategory
        )
        
        // 通知刷新
        onTransactionAdded()
        
        // 关闭视图
        dismiss()
    }
}

struct TypeButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? Color.white : color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? color : Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color, lineWidth: 2)
                )
                .shadow(radius: 3)
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.white : Color(hex: category.color))
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color(hex: category.color) : Color(hex: category.backgroundColor))
                    .cornerRadius(12)
                
                Text(category.name)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? Color(hex: category.color) : Color.gray)
            }
        }
    }
}

// 扩展以支持指定圆角
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    DashboardView()
}
