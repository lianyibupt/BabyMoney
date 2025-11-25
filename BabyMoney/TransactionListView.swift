import SwiftUI

// 完整交易列表视图
struct TransactionListView: View {
    @AppStorage("currentUserName") var userName: String = "蓝莓"
    @Environment(\.dismiss) var dismiss
    @State private var transactions: [Transaction] = []
    @State private var selectedFilter: FilterType = .all
    @State private var selectedTransaction: Transaction?
    @State private var showDetail = false
    
    enum FilterType: String, CaseIterable {
        case all = "全部"
        case income = "收入"
        case expense = "支出"
    }
    
    var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all:
            return transactions
        case .income:
            return transactions.filter { $0.type == "in" }
        case .expense:
            return transactions.filter { $0.type == "out" }
        }
    }
    
    var groupedTransactions: [(String, [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { $0.date }
        return grouped.sorted { $0.key > $1.key }.map { ($0.key, $0.value) }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF8585"))
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("交易记录")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    // 占位，保持标题居中
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.top, 20)
                
                // 筛选器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(FilterType.allCases, id: \.self) { filter in
                            FilterButton(
                                title: filter.rawValue,
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 15)
                
                // 交易列表
                if groupedTransactions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(Color.gray.opacity(0.5))
                            .padding(.top, 100)
                        
                        Text("暂无交易记录")
                            .font(.system(size: 18))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(groupedTransactions, id: \.0) { date, transactionsForDate in
                                VStack(alignment: .leading, spacing: 10) {
                                    // 日期标题
                                    Text(date)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color.gray)
                                        .padding(.horizontal, 20)
                                    
                                    // 该日期的交易
                                    VStack(spacing: 10) {
                                        ForEach(transactionsForDate, id: \.id) { transaction in
                                            TransactionListRow(transaction: transaction)
                                                .onTapGesture {
                                                    selectedTransaction = transaction
                                                    showDetail = true
                                                }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 10)
                    }
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            if let transaction = selectedTransaction {
                TransactionDetailView(transaction: transaction) {
                    deleteTransaction(transaction)
                }
            }
        }
        .onAppear {
            loadTransactions()
        }
    }
    
    private func loadTransactions() {
        let users = DataManager.shared.getAllUsers()
        guard let user = users.first(where: { $0.name == userName }) else {
            return
        }
        transactions = DataManager.shared.getTransactionsForUser(user.id)
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        // 这里需要在DataManager中添加删除方法
        // 暂时从本地列表中移除
        transactions.removeAll { $0.id == transaction.id }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(isSelected ? Color(hex: "FF8585") : Color.white)
                .cornerRadius(20)
                .shadow(radius: isSelected ? 3 : 1)
        }
    }
}

struct TransactionListRow: View {
    let transaction: Transaction
    
    var categoryInfo: (icon: String, name: String, color: String)? {
        guard let categoryId = transaction.categoryId,
              let category = Category.getCategoryById(categoryId) else {
            return nil
        }
        return (category.iconName, category.name, category.color)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2)
                
                if let info = categoryInfo {
                    Image(systemName: info.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: info.color))
                } else {
                    Image(systemName: transaction.type == "in" ? "arrow.down.circle" : "arrow.up.circle")
                        .font(.system(size: 24))
                        .foregroundColor(transaction.type == "in" ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
                }
            }
            
            // 交易信息
            VStack(alignment: .leading, spacing: 5) {
                Text(categoryInfo?.name ?? (transaction.type == "in" ? "收入" : "支出"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
                
                Text(transaction.time)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            // 金额 - 放大字体
            Text(transaction.type == "in" ? "+¥\(String(format: "%.2f", transaction.amount))" : "-¥\(String(format: "%.2f", transaction.amount))")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(transaction.type == "in" ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
