import SwiftUI

// Reports View Content - 嵌入到DashboardView的报告页面内容
struct ReportsViewContent: View {
    let userName: String
    @State private var selectedTimeRange: TimeRangeType = .month
    @State private var totalIncome: Double = 0
    @State private var totalExpense: Double = 0
    @State private var transactions: [Transaction] = []
    
    enum TimeRangeType: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 顶部标题
                Text("消费报告")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(.top, 60)
                
                // 时间范围选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(TimeRangeType.allCases, id: \.self) { range in
                            TimeRangeButtonView(
                                title: range.rawValue,
                                isSelected: selectedTimeRange == range
                            ) {
                                selectedTimeRange = range
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // 收支统计卡片
                HStack {
                    StatCardView(title: "总收入", amount: "+￥\(String(format: "%.2f", totalIncome))", color: Color(hex: "4CAF50"))
                    StatCardView(title: "总支出", amount: "-￥\(String(format: "%.2f", totalExpense))", color: Color(hex: "FF6B6B"))
                }
                .padding(.horizontal, 20)
                
                // 提示信息
                VStack(spacing: 15) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "FF8585"))
                        .padding(.top, 40)
                    
                    Text("报告功能")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
                    
                    Text("查看您的收支趋势和消费分类")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.vertical, 40)
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        let users = DataManager.shared.getAllUsers()
        guard let user = users.first(where: { $0.name == userName }) else {
            return
        }
        
        transactions = DataManager.shared.getTransactionsForUser(user.id)
        
        // 计算总收入和总支出
        totalIncome = transactions
            .filter { $0.type == "in" }
            .reduce(0) { $0 + $1.amount }
        
        totalExpense = transactions
            .filter { $0.type == "out" }
            .reduce(0) { $0 + $1.amount }
    }
}

struct TimeRangeButtonView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(isSelected ? Color.white : Color.gray)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(isSelected ? Color(hex: "FF8585") : Color.white)
                .cornerRadius(20)
                .shadow(radius: isSelected ? 3 : 1)
        }
    }
}

struct StatCardView: View {
    let title: String
    let amount: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 3)
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
                
                Text(amount)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity)
    }
}

// AI Advice View Content - 嵌入到DashboardView的建议页面内容
struct AIAdviceViewContent: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 顶部标题
                Text("智慧兔兔理财助手")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(.top, 60)
                
                // 兔子图标
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFEEEE"))
                        .frame(width: 120, height: 120)
                    
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF8585"))
                            .frame(width: 60, height: 60)
                        
                        // 兔子耳朵
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 12, height: 30)
                                .rotationEffect(Angle(degrees: -20))
                        }
                        .offset(x: -12, y: -30)
                        
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 12, height: 30)
                                .rotationEffect(Angle(degrees: 20))
                        }
                        .offset(x: 12, y: -30)
                    }
                }
                .padding(.bottom, 20)
                
                // 提示信息
                VStack(spacing: 15) {
                    Text("AI理财建议功能")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
                    
                    Text("正在准备集成DeepSeek服务...")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("即将为您提供:")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureItemView(icon: "chart.line.uptrend.xyaxis", text: "消费趋势分析")
                        FeatureItemView(icon: "lightbulb.fill", text: "智能理财建议")
                        FeatureItemView(icon: "target", text: "存钱目标规划")
                        FeatureItemView(icon: "bell.fill", text: "消费提醒")
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer().frame(height: 100)
            }
        }
    }
}

struct FeatureItemView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "FF8585"))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color.black)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
