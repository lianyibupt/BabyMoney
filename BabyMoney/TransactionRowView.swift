import SwiftUI

// 新的交易行视图，用于显示真实的Transaction数据
struct TransactionRowView: View {
    let transaction: Transaction
    
    var categoryInfo: (icon: String, name: String, color: String)? {
        guard let categoryId = transaction.categoryId,
              let category = Category.getCategoryById(categoryId) else {
            return nil
        }
        return (category.iconName, category.name, category.color)
    }
    
    var body: some View {
        HStack {
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
                    Image(systemName: transaction.type == "in" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(transaction.type == "in" ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
                }
            }
            
            Spacer().frame(width: 15)
            
            // 交易信息
            VStack(alignment: .leading) {
                Text(categoryInfo?.name ?? (transaction.type == "in" ? "收入" : "支出"))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.black)
                
                Text("\(transaction.date) \(transaction.time)")
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
