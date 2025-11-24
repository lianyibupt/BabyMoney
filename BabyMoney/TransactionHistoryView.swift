import SwiftUI
import SwiftData

struct TransactionHistoryView: View {
    let user: User
    @State private var transactions: [Transaction] = []
    @State private var filterType: TransactionType? = nil
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // 筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        FilterButton(
                            title: "全部", 
                            isSelected: filterType == nil
                        ) { 
                            filterType = nil
                            loadTransactions()
                        }
                        
                        FilterButton(
                            title: "存入", 
                            isSelected: filterType == .income
                        ) { 
                            filterType = .income
                            loadTransactions()
                        }
                        
                        FilterButton(
                            title: "取出", 
                            isSelected: filterType == .expense
                        ) { 
                            filterType = .expense
                            loadTransactions()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                
                // 交易列表
                List {
                    if transactions.isEmpty {
                        Text("暂无交易记录")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        // 按日期分组显示交易记录
                        ForEach(groupedTransactions, id: \.key) { date, dayTransactions in
                            Section(header: DateHeader(date: date)) {
                                ForEach(dayTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("交易记录")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("完成") { dismiss() })
            .onAppear {
                loadTransactions()
                // 监听交易更新通知
                NotificationCenter.default.addObserver(
                    forName: Notification.Name("TransactionsUpdated"), 
                    object: nil,
                    queue: .main
                ) { _ in
                    loadTransactions()
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
    
    // 加载交易记录
    private func loadTransactions() {
        transactions = DataManager.shared.getTransactions(for: user.id, type: filterType)
    }
    
    // 按日期分组的交易记录
    private var groupedTransactions: [(key: Date, value: [Transaction])] {
        // 按日期分组
        let grouped = Dictionary(
            grouping: transactions
        ) { transaction -> Date in
            // 将日期标准化为只保留年月日
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: transaction.date)
            return calendar.date(from: components) ?? transaction.date
        }
        
        // 转换为有序数组并按日期降序排列
        return grouped
            .sorted { $0.key > $1.key }
    }
}

// 日期头部视图
struct DateHeader: View {
    let date: Date
    
    var body: some View {
        HStack {
            Text(formattedDate)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.horizontal, 12)
    }
    
    private var formattedDate: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let currentDate = calendar.startOfDay(for: date)
        
        if currentDate == today {
            return "今天"
        } else if currentDate == yesterday {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
    }
}

// 交易记录行视图
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // 图标
            ZStack {
                Color(hex: category?.backgroundColor ?? "#F5F5F5")
                    .frame(width: 48, height: 48)
                    .cornerRadius(12)
                
                Image(systemName: category?.iconName ?? "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: category?.color ?? "#000000"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category?.name ?? "其他")
                    .font(.system(size: 16, weight: .medium))
                
                Text(formattedTime)
                    .font(.system(size: 12, weight: .light))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 12)
            
            Spacer()
            
            Text(amountText)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(transaction.type == .income ? .green : .red)
        }
        .padding(.vertical, 8)
    }
    
    private var category: Category? {
        Category.getCategoryById(id: transaction.categoryId)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: transaction.date)
    }
    
    private var amountText: String {
        let prefix = transaction.type == .income ? "+" : "-"
        return "\(prefix)¥\(String(format: "%.2f", transaction.amount))"
    }
}

// 筛选按钮
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.gray.opacity(0.1))
                .cornerRadius(20)
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
    
    return TransactionHistoryView(user: user)
}
