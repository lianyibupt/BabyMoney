import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "FFF5F5") // 浅粉色背景
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // 标题区域
                    VStack(spacing: 8) {
                        Text("宝宝存钱罐")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "FF8585"))
                            .padding(.top, 60)
                    }
                    
                    // 用户卡片区域
                    HStack(spacing: 30) {
                        // 蓝莓卡片
                        UserCard(
                            name: "蓝莓",
                            iconColor: Color(hex: "FF6B6B"),
                            cardColor: Color.white,
                            borderColor: Color(hex: "FFD1D1"),
                            textColor: Color(hex: "FF6B6B")
                        )
                        
                        // 樱桃卡片
                        UserCard(
                            name: "樱桃",
                            iconColor: Color(hex: "9B6BFF"),
                            cardColor: Color.white,
                            borderColor: Color(hex: "E4D1FF"),
                            textColor: Color(hex: "9B6BFF")
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct UserCard: View {
    let name: String
    let iconColor: Color
    let cardColor: Color
    let borderColor: Color
    let textColor: Color
    
    var body: some View {
        NavigationLink(destination: DashboardView()) {
            VStack(spacing: 20) {
                // 兔子图标
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .shadow(radius: 4)
                    
                    Circle()
                        .fill(Color(hex: name == "蓝莓" ? "F4F0FF" : "FFEEEE"))
                        .frame(width: 70, height: 70)
                    
                    // 简化的兔子图标
                    ZStack {
                        Circle()
                            .fill(iconColor)
                            .frame(width: 30, height: 30)
                        
                        // 兔子耳朵
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(iconColor)
                                .frame(width: 6, height: 20)
                                .rotationEffect(Angle(degrees: -20))
                        }
                        .offset(x: -6, y: -20)
                        
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(iconColor)
                                .frame(width: 6, height: 20)
                                .rotationEffect(Angle(degrees: 20))
                        }
                        .offset(x: 6, y: -20)
                    }
                }
                
                // 用户名
                Text(name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(textColor)
                
                // 点击进入提示
                Text("点击进入")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            .padding(30)
            .background(cardColor)
            .cornerRadius(20)
            .border(borderColor, width: 2)
            .shadow(radius: 5)
            .frame(width: 150)
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
