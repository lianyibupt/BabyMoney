import SwiftUI

struct ReportsView: View {
    let userName: String = "姐姐" // 模拟用户名
    @State private var selectedTimeRange: TimeRange = .month
    @State private var activeTab = 1 // 选中的是报告标签
    
    enum TimeRange: String, CaseIterable {
        case week = "本周"
        case month = "本月"
        case year = "本年"
    }
    
    // 模拟收支趋势数据
    let trendData = [
        TrendItem(date: "周一", income: 0, expense: 15),
        TrendItem(date: "周二", income: 20, expense: 5),
        TrendItem(date: "周三", income: 0, expense: 25),
        TrendItem(date: "周四", income: 30, expense: 10),
        TrendItem(date: "周五", income: 0, expense: 20),
        TrendItem(date: "周六", income: 0, expense: 15),
        TrendItem(date: "周日", income: 50, expense: 0)
    ]
    
    // 模拟消费分类数据
    let categoryData = [
        CategoryItem(name: "零食", amount: 30, color: Color(hex: "FF6B6B")),
        CategoryItem(name: "文具", amount: 15, color: Color(hex: "4CAF50")),
        CategoryItem(name: "玩具", amount: 20, color: Color(hex: "9B6BFF")),
        CategoryItem(name: "其他", amount: 10, color: Color(hex: "FF9800"))
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5") // 浅粉色背景
                .ignoresSafeArea()
            
            VStack {
                // 顶部标题
                Text("消费报告")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.black)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                
                // 时间范围选择
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            TimeRangeButton(
                                title: range.rawValue,
                                isSelected: selectedTimeRange == range
                            ) {
                                selectedTimeRange = range
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer().frame(height: 20)
                
                // 收支统计卡片
                HStack {
                    StatCard(title: "总收入", amount: "+¥100.00", color: Color(hex: "4CAF50"))
                    StatCard(title: "总支出", amount: "-¥95.00", color: Color(hex: "FF6B6B"))
                }
                .padding(.horizontal, 20)
                
                Spacer().frame(height: 20)
                
                // 收支趋势图表
                VStack(alignment: .leading, spacing: 15) {
                    Text("收支趋势")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 5)
                        
                        VStack(spacing: 20) {
                            // 图表标题
                            HStack {
                                LegendItem(color: Color(hex: "4CAF50"), text: "收入")
                                LegendItem(color: Color(hex: "FF6B6B"), text: "支出")
                            }
                            .padding(.top, 10)
                            
                            // 图表内容
                            TrendChart(data: trendData)
                                .frame(height: 200)
                                .padding(.horizontal, 10)
                        }
                        .padding()
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer().frame(height: 20)
                
                // 消费分类饼图
                VStack(alignment: .leading, spacing: 15) {
                    Text("消费分类")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(.horizontal, 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 5)
                        
                        HStack(spacing: 20) {
                            // 饼图
                            PieChart(data: categoryData)
                                .frame(width: 150, height: 150)
                            
                            // 分类列表
                            VStack(spacing: 12) {
                                ForEach(categoryData) { category in
                                    CategoryRow(category: category)
                                }
                            }
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
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
    }
}

struct TrendItem: Identifiable {
    let id = UUID()
    let date: String
    let income: Double
    let expense: Double
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct TimeRangeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -\u003e Void
    
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

struct StatCard: View {
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

struct LegendItem: View {
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
        }
    }
}

struct TrendChart: View {
    let data: [TrendItem]
    
    var body: some View {
        GeometryReader {\ geometry in
            HStack(spacing: geometry.size.width / CGFloat(data.count * 2)) {
                ForEach(data) { item in
                    VStack {
                        // 收入柱形
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "4CAF50"))
                                .frame(
                                    width: geometry.size.width / CGFloat(data.count * 3),
                                    height: item.income > 0 ? (item.income / 50) * geometry.size.height * 0.6 : 0
                                )
                            
                            if item.income > 0 {
                                Text("¥\(Int(item.income))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "4CAF50"))
                                    .offset(y: -5)
                            }
                        }
                        
                        Spacer().frame(height: 10)
                        
                        // 支出柱形
                        ZStack(alignment: .top) {
                            if item.expense > 0 {
                                Text("¥\(Int(item.expense))")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "FF6B6B"))
                                    .offset(y: -15)
                            }
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "FF6B6B"))
                                .frame(
                                    width: geometry.size.width / CGFloat(data.count * 3),
                                    height: item.expense > 0 ? (item.expense / 50) * geometry.size.height * 0.6 : 0
                                )
                        }
                        
                        // 日期标签
                        Text(item.date)
                            .font(.system(size: 12))
                            .foregroundColor(Color.gray)
                            .padding(.top, 10)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct PieChart: View {
    let data: [CategoryItem]
    
    var body: some View {
        ZStack {
            ForEach(0..<data.count) { index in
                let startAngle = calculateStartAngle(at: index)
                let endAngle = calculateEndAngle(at: index)
                
                PieSlice(
                    startAngle: startAngle,
                    endAngle: endAngle,
                    color: data[index].color
                )
            }
            
            // 中心圆
            Circle()
                .fill(Color.white)
                .frame(width: 50, height: 50)
        }
    }
    
    private func totalAmount() -\u003e Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    private func calculateStartAngle(at index: Int) -\u003e Double {
        var startAngle: Double = -90 // 从顶部开始
        for i in 0..<index {
            startAngle += (data[i].amount / totalAmount()) * 360
        }
        return startAngle
    }
    
    private func calculateEndAngle(at index: Int) -\u003e Double {
        return calculateStartAngle(at: index) + (data[index].amount / totalAmount()) * 360
    }
}

struct PieSlice: View {
    let startAngle: Double
    let endAngle: Double
    let color: Color
    
    var body: some View {
        Path {
            path in
            let center = CGPoint(x: path.currentPoint?.x ?? 75, y: path.currentPoint?.y ?? 75)
            path.move(to: center)
            path.addArc(
                center: center,
                radius: 75,
                startAngle: Angle(degrees: startAngle),
                endAngle: Angle(degrees: endAngle),
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
    }
}

struct CategoryRow: View {
    let category: CategoryItem
    
    var body: some View {
        HStack {
            Circle()
                .fill(category.color)
                .frame(width: 16, height: 16)
            
            Text(category.name)
                .font(.system(size: 14))
                .foregroundColor(Color.black)
            
            Spacer()
            
            Text("¥\(Int(category.amount))")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.black)
        }
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

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(\u0026rgb)
        
        let r = Double((rgb \u003e\u003e 16) \u0026 0xFF) / 255.0
        let g = Double((rgb \u003e\u003e 8) \u0026 0xFF) / 255.0
        let b = Double(rgb \u0026 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ReportsView()
}