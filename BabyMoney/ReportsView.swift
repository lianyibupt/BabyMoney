import SwiftUI
import Charts
import SwiftData

struct ReportsView: View {
    let user: User
    @State private var selectedTimeRange: TimeRange = .month
    @State private var chartData: [ChartData] = []
    @State private var categoryData: [CategoryData] = []
    @State private var statistics: Statistics = Statistics()
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
        
        var id: String { self.rawValue }
    }
    
    struct Statistics {
        var totalIncome: Double = 0
        var totalExpense: Double = 0
        var balance: Double = 0
        var expenseCount: Int = 0
        var incomeCount: Int = 0
    }
    
    struct ChartData: Identifiable {
        let id = UUID()
        let date: Date
        let income: Double
        let expense: Double
        
        var dateLabel: String {
            let formatter = DateFormatter()
            switch selectedTimeRange {
            case .week:
                formatter.dateFormat = "E"
            case .month:
                formatter.dateFormat = "dd"
            case .year:
                formatter.dateFormat = "MM月"
            }
            return formatter.string(from: date)
        }
    }
    
    struct CategoryData: Identifiable {
        let id = UUID()
        let categoryName: String
        let amount: Double
        let color: Color
        
        var percentage: Double { statistics.totalExpense > 0 ? (amount / statistics.totalExpense) * 100 : 0 }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 时间范围选择器
                    Picker("时间范围", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases) { range in
                            Text(range.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onChange(of: selectedTimeRange) { _ in
                        loadData()
                    }
                    
                    // 统计数据卡片
                    StatisticsCard(statistics: statistics)
                    
                    // 收支趋势图表
                    SectionCard(title: "收支趋势") {
                        if chartData.isEmpty {
                            Text("暂无数据")
                                .foregroundColor(.gray)
                                .padding(32)
                        } else {
                            Chart {
                                ForEach(chartData) {\ data in
                                    BarMark(
                                        x: .value("日期", data.dateLabel),
                                        y: .value("收入", data.income)
                                    )
                                    .foregroundStyle(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    BarMark(
                                        x: .value("日期", data.dateLabel),
                                        y: .value("支出", -data.expense)
                                    )
                                    .foregroundStyle(Color.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                            .chartYScale(domain: .automatic(includesZero: true))
                            .chartYAxis {
                                AxisMarks(position: .trailing) {
                                    AxisGridLine()
                                    AxisValueLabel {
                                        if let value = $0.as(Double.self) {
                                            Text("\(value > 0 ? "+" : "")¥\(String(format: "%.0f", value))")
                                        }
                                    }
                                }
                            }
                            .frame(height: 250)
                            .padding(.horizontal, 8)
                        }
                    }
                    
                    // 消费分类饼图
                    SectionCard(title: "消费分类") {
                        if categoryData.isEmpty {
                            Text("暂无数据")
                                .foregroundColor(.gray)
                                .padding(32)
                        } else {
                            Chart {
                                ForEach(categoryData) {\ data in
                                    SectorMark(
                                        angle: .value("金额", data.amount),
                                        innerRadius: .ratio(0.5),
                                        outerRadius: .ratio(0.9)
                                    )
                                    .foregroundStyle(data.color)
                                    .annotation(position: .overlay) {
                                        Text("\(String(format: "%.0f", data.percentage))%")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(height: 250)
                            .padding(.horizontal, 16)
                            
                            // 图例
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(categoryData) {\ data in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 8) {
                                                Rectangle()
                                                    .frame(width: 12, height: 12)
                                                    .foregroundColor(data.color)
                                                    .cornerRadius(2)
                                                
                                                Text(data.categoryName)
                                                    .font(.system(size: 14))
                                            }
                                            
                                            Text("¥\(String(format: "%.2f", data.amount))")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .padding(8)
                                        .background(Color.gray.opacity(0.05))
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    
                    // 最常消费分类
                    SectionCard(title: "消费分析") {
                        if categoryData.isEmpty {
                            Text("暂无数据")
                                .foregroundColor(.gray)
                                .padding(32)
                        } else {
                            let topCategory = categoryData.max { $0.amount < $1.amount }
                            
                            VStack(spacing: 16) {
                                Text("最常消费分类")
                                    .font(.system(size: 16, weight: .medium))
                                    
                                HStack(spacing: 12) {
                                    if let category = topCategory {
                                        ZStack {
                                            category.color
                                                .frame(width: 48, height: 48)
                                                .cornerRadius(12)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(category.categoryName)
                                                .font(.system(size: 18, weight: .bold))
                                            Text("¥\(String(format: "%.2f", category.amount))")
                                                .font(.system(size: 14))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                
                                Divider()
                                
                                // 平均消费
                                HStack {
                                    Text("平均每日消费")
                                        .font(.system(size: 16))
                                    Spacer()
                                    Text("¥\(averageDailyExpense)")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                            .padding(16)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("消费报告")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完成") { 
                // 关闭视图
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    windowScene.keyWindow?.rootViewController?.dismiss(animated: true)
                }
            })
            .onAppear {
                loadData()
                // 监听交易更新通知
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("TransactionsUpdated"), 
                    object: nil,
                    queue: .main
                ) { _ in
                    loadData()
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    forName: Notification.Name("TransactionsUpdated"), 
                    object: nil
                )
            }
        }
    }
    
    // 加载数据
    private func loadData() {
        let transactions = getFilteredTransactions()
        calculateStatistics(transactions: transactions)
        generateChartData(transactions: transactions)
        generateCategoryData(transactions: transactions)
    }
    
    // 获取筛选后的交易记录
    private func getFilteredTransactions() -> [Transaction] {
        let transactions = DataManager.shared.getTransactions(for: user.id)
        let calendar = Calendar.current
        let now = Date()
        
        var startDate: Date
        switch selectedTimeRange {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return transactions.filter { $0.date >= startDate }
    }
    
    // 计算统计数据
    private func calculateStatistics(transactions: [Transaction]) {
        let incomeTransactions = transactions.filter { $0.type == .income }
        let expenseTransactions = transactions.filter { $0.type == .expense }
        
        statistics.totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }
        statistics.totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
        statistics.balance = statistics.totalIncome - statistics.totalExpense
        statistics.incomeCount = incomeTransactions.count
        statistics.expenseCount = expenseTransactions.count
    }
    
    // 生成趋势图表数据
    private func generateChartData(transactions: [Transaction]) {
        let calendar = Calendar.current
        var dataMap: [Date: (income: Double, expense: Double)] = [:]
        
        // 根据时间范围确定分组粒度
        let components: Set<Calendar.Component>
        let range: Int
        switch selectedTimeRange {
        case .week:
            components = [.year, .month, .day]
            range = 7
        case .month:
            components = [.year, .month, .day]
            range = 30
        case .year:
            components = [.year, .month]
            range = 12
        }
        
        // 初始化数据点
        for i in 0..<range {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let key = calendar.date(from: calendar.dateComponents(components, from: date)) ?? date
            dataMap[key] = (income: 0, expense: 0)
        }
        
        // 统计交易数据
        for transaction in transactions {
            let key = calendar.date(from: calendar.dateComponents(components, from: transaction.date)) ?? transaction.date
            if var data = dataMap[key] {
                if transaction.type == .income {
                    data.income += transaction.amount
                } else {
                    data.expense += transaction.amount
                }
                dataMap[key] = data
            }
        }
        
        // 转换为图表数据
        chartData = dataMap
            .map { ChartData(date: $0.key, income: $0.value.income, expense: $0.value.expense) }
            .sorted { $0.date < $1.date }
    }
    
    // 生成分类数据
    private func generateCategoryData(transactions: [Transaction]) {
        let expenseTransactions = transactions.filter { $0.type == .expense }
        var categoryMap: [String: Double] = [:]
        
        // 按分类统计支出
        for transaction in expenseTransactions {
            categoryMap[transaction.categoryId, default: 0] += transaction.amount
        }
        
        // 转换为分类数据
        categoryData = categoryMap
            .compactMap { categoryId, amount in
                guard let category = Category.getCategoryById(id: categoryId) else { return nil }
                return CategoryData(
                    categoryName: category.name,
                    amount: amount,
                    color: Color(hex: category.color)
                )
            }
            .sorted { $0.amount > $1.amount }
    }
    
    // 平均每日消费
    private var averageDailyExpense: String {
        let days: Int
        switch selectedTimeRange {
        case .week:
            days = 7
        case .month:
            days = 30
        case .year:
            days = 365
        }
        
        let average = statistics.totalExpense / Double(days)
        return String(format: "%.2f", average)
    }
}

// 统计数据卡片视图
struct StatisticsCard: View {
    let statistics: ReportsView.Statistics
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                label: "总收入", 
                value: "¥\(String(format: "%.2f", statistics.totalIncome))",
                color: .green
            )
            
            Divider().frame(height: 60)
            
            StatItem(
                label: "总支出", 
                value: "¥\(String(format: "%.2f", statistics.totalExpense))",
                color: .red
            )
            
            Divider().frame(height: 60)
            
            StatItem(
                label: "结余", 
                value: "¥\(String(format: "%.2f", statistics.balance))",
                color: statistics.balance >= 0 ? .blue : .orange
            )
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2, y: 2)
        .padding(.horizontal, 16)
    }
}

// 统计项视图
struct StatItem: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
    }
}

// 区块卡片视图
struct SectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.top, 16)
            
            ZStack {
                Color.white
                content
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2, y: 2)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    // 创建测试数据
    let user = User(
        id: "test", 
        name: "测试用户", 
        color: "#FF6B6B", 
        textColor: "#FFFFFF", 
        borderColor: "#FF8787", 
        iconColor: "#FFE5E5",
        balance: 100.0
    )
    
    return ReportsView(user: user)
}
