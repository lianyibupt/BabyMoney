import SwiftUI

// 交易详情视图
struct TransactionDetailView: View {
    let transaction: Transaction
    @AppStorage("currentUserName") var userName: String = "蓝莓"
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    var onDelete: () -> Void
    
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
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF8585"))
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("交易详情")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.black)
                    
                    Spacer()
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .padding()
                    }
                }
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 金额显示
                        VStack(spacing: 10) {
                            Text(transaction.type == "in" ? "收入" : "支出")
                                .font(.system(size: 16))
                                .foregroundColor(Color.gray)
                            
                            Text(transaction.type == "in" ? "+¥\(String(format: "%.2f", transaction.amount))" : "-¥\(String(format: "%.2f", transaction.amount))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(transaction.type == "in" ? Color(hex: "4CAF50") : Color(hex: "FF6B6B"))
                        }
                        .padding(.top, 40)
                        
                        // 详情卡片
                        VStack(spacing: 0) {
                            // 分类
                            if let categoryId = transaction.categoryId,
                               let category = Category.getCategoryById(categoryId) {
                                DetailRow(
                                    icon: category.iconName,
                                    title: "分类",
                                    value: category.name,
                                    iconColor: Color(hex: category.color)
                                )
                                
                                Divider()
                                    .padding(.horizontal, 20)
                            }
                            
                            // 日期
                            DetailRow(
                                icon: "calendar",
                                title: "日期",
                                value: transaction.date,
                                iconColor: Color(hex: "FF8585")
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            // 时间
                            DetailRow(
                                icon: "clock",
                                title: "时间",
                                value: transaction.time,
                                iconColor: Color(hex: "FF8585")
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
        }
        .alert("删除交易", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("确定要删除这笔交易吗？")
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.gray)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}
