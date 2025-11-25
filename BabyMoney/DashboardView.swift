import SwiftUI

struct DashboardView: View {
    let userName: String
    @State private var balance: String = "¥0.00"
    @State private var showAddTransaction = false
    @State private var activeTab = 0
    
    // 模拟交易数据
    let recentTransactions = [
        TransactionItem(name: "买零食", type: .expense, amount: "-¥12.50", date: "今天 14:30", icon: "🍬"),
        TransactionItem(name: "零花钱", type: .income, amount: "+¥50.00", date: "今天 12:00", icon: "💰"),
        TransactionItem(name: "卖旧书", type: .income, amount: "+¥8.00", date: "昨天 16:45", icon: "📚"),
        TransactionItem(name: "买文具", type: .expense, amount: "-¥15.00", date: "昨天 10:20", icon: "✏️")
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5") // 浅粉色背景
                .ignoresSafeArea()
            
            VStack {
                // 顶部用户信息和设置按钮
                HStack {
                    VStack(alignment: .leading) {
                        Text("欢迎，\(userName)")
                            .font(.system(size: 16))
                            .foregroundColor(Color.gray)
                        Text("今天也要加油哦！")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // 设置按钮点击事件
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(hex: "FF8585"))
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // 账户卡片
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: userName == "姐姐" ? "FF6B6B" : "9B6BFF"))
                        .padding(.horizontal, 20)
                        .shadow(radius: 5)
                    
                    VStack(spacing: 10) {
                        Text("账户余额")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.9))
                        
                        Text(balance)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color.white)
                        
                        HStack(spacing: 20) {
                            // 收入
                            VStack {
                                Text("本月收入")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text("+¥50.00")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.white)
                            }
                            
                            Spacer()
                            
                            // 支出
                            VStack {
                                Text("本月支出")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text("-¥27.50")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.white)
                            }
                        }
                    }
                    .padding(25)
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
                        // 查看全部按钮点击事件
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
                        ForEach(recentTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
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
                .padding(.bottom, 80)
                
                // 底部导航栏
                HStack(spacing: 0) {
                    TabButton(index: 0, icon: "house", title: "主页", isActive: $activeTab)
                    TabButton(index: 1, icon: "chart.pie", title: "报告", isActive: $activeTab)
                    TabButton(index: 2, icon: "brain", title: "建议", isActive: $activeTab)
                    TabButton(index: 3, icon: "person", title: "我的", isActive: $activeTab)
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                .background(Color.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 10, y: -5)
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
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
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isActive == index ? Color(hex: "FF8585") : Color.gray)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isActive == index ? Color(hex: "FF8585") : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct AddTransactionView: View {
    @State private var amount: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 标题
                Text("记一笔")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(.top, 60)
                
                // 金额输入
                VStack(spacing: 10) {
                    Text("金额")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("输入金额", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
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
                        TypeButton(title: "收入", color: Color(hex: "4CAF50"))
                        TypeButton(title: "支出", color: Color(hex: "FF6B6B"))
                    }
                }
                .padding(.horizontal, 30)
                
                // 描述输入
                VStack(spacing: 10) {
                    Text("描述")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("添加描述", text: .constant(""))
                        .font(.system(size: 16))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // 确认按钮
                Button(action: {
                    dismiss()
                }) {
                    Text("确认")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "FF8585"))
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 80)
            }
        }
    }
}

struct TypeButton: View {
    let title: String
    let color: Color
    @State private var isSelected: Bool = false
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? Color.white : color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? color : Color.white)
                .cornerRadius(15)
                .border(color, width: 2)
                .shadow(radius: 3)
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
    DashboardView(userName: "姐姐")
}