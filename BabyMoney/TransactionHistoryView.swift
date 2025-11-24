import SwiftUI
import Foundation

// 创建完全独立的视图实现，避免命名冲突
struct HistoryView: View {
    // 简单的内部数据结构
    private struct HistoryItem: Identifiable {
        let id = UUID()
        let amount: Double
        let isIncome: Bool
        let date: String
        let title: String
    }
    
    @State private var items: [HistoryItem] = []
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                // 导航栏
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Text("交易记录")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .padding()
                    }
                }
                
                // 内容
                Text("交易记录页面")
                    .padding()
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func loadItems() {
        items = [
            HistoryItem(amount: 100.0, isIncome: true, date: "2023-10-15", title: "收入"),
            HistoryItem(amount: 50.0, isIncome: false, date: "2023-10-16", title: "支出")
        ]
    }
}

// 重命名原始结构体以避免冲突
struct TransactionHistoryView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HistoryView()
    }
}

struct TransactionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionHistoryView()
    }
}