//
//  ContentView.swift
//  BabyMoney
//
//  Created by 易炼 on 2025/11/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var users: [User] = []
    @State private var selectedUser: User? = nil
    @State private var showDashboard: Bool = false
    
    var body: some View {
        ZStack {
            if showDashboard, let user = selectedUser {
                DashboardView(user: user)
                    .onDisappear {
                        // 从Dashboard返回时重新加载用户数据
                        loadUsers()
                    }
                    .transition(.move(edge: .trailing))
            } else {
                VStack {
                    Spacer()
                    
                    // 标题
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "rabbit.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.orange)
                            .padding(8)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("宝宝存钱罐")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .padding(.bottom, 50)
                    
                    // 用户卡片网格
                    VStack(spacing: 24) {
                        ForEach(users, id: \.id) { user in
                            UserCard(user: user, onSelect: { selectedUser in
                                self.selectedUser = selectedUser
                                withAnimation {
                                    showDashboard = true
                                }
                            })
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .background(Color.orange.opacity(0.05).edgesIgnoringSafeArea(.all))
                .transition(.move(edge: .leading))
            }
        }
        .onAppear {
            loadUsers()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDataUpdated"))) {
            _ in
            loadUsers()
        }
    }
    
    private func loadUsers() {
        users = DataManager.shared.getAllUsers()
    }
}

// 用户卡片组件
struct UserCard: View {
    let user: User
    let onSelect: (User) -> Void
    
    var body: some View {
        Button(action: {
            onSelect(user)
        }) {
            VStack(spacing: 16) {
                // 头像区域
                ZStack {
                    Color(hex: user.color)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                    
                    Image(systemName: "rabbit.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color(hex: user.iconColor))
                }
                
                // 用户名
                Text(user.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: user.textColor))
                
                // 余额显示（可选）
                Text("余额: ¥\(user.balance, specifier: "%.2f")")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .background(Color.white)
            .cornerRadius(32)
            .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
            .border(Color(hex: user.borderColor), width: 4)
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .gesture(
            TapGesture()
                .onEnded { _ in
                    withAnimation {
                        onSelect(user)
                    }
                }
        )
    }
}

// 颜色扩展，支持从十六进制字符串创建颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Transaction.self], inMemory: true)
}
