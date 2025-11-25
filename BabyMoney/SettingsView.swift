import SwiftUI

struct SettingsView: View {
    @State private var showPasswordView = false
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @AppStorage("currentUserName") var currentUserName = "蓝莓"
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5") // 浅粉色背景
                .ignoresSafeArea()
            
            VStack {
                // 顶部导航栏
                HStack {
                    Spacer()
                    Text("设置")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    // 用户信息卡片
                    UserInfoCard(userName: currentUserName)
                    
                    SettingsSection(title: "账户切换") {
                        VStack(spacing: 12) {
                            Picker("账户", selection: $currentUserName) {
                                Text("蓝莓").tag("蓝莓")
                                Text("樱桃").tag("樱桃")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // 安全设置
                    SettingsSection(title: "安全设置") {
                        VStack(spacing: 0) {
                            SettingRow(
                            icon: Image(systemName: "lock.fill"),
                            title: "修改密码",
                            subtitle: "点击修改当前密码",
                            showArrow: true
                            )
                        
                            SettingRow(
                            icon: Image(systemName: "faceid.fill"),
                            title: "生物识别",
                            subtitle: "使用Face ID或Touch ID解锁",
                            showArrow: false
                            )
                        }
                    }
                    
                    // 通知设置
                    SettingsSection(title: "通知设置") {
                        VStack(spacing: 0) {
                            SettingRow(
                            icon: Image(systemName: "bell.fill"),
                            title: "通知提醒",
                            subtitle: "开启后接收交易提醒",
                            showArrow: false
                        ) {
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "FF8585"))
                        }
                        
                            SettingRow(
                            icon: Image(systemName: "speaker.fill"),
                            title: "声音提醒",
                            subtitle: "交易时发出提示音",
                            showArrow: false
                        ) {
                            Toggle("", isOn: $soundEnabled)
                                .labelsHidden()
                                .tint(Color(hex: "FF8585"))
                        }
                        }
                    }
                    
                    // 关于我们
                    SettingsSection(title: "关于我们") {
                        VStack(spacing: 0) {
                            SettingRow(
                            icon: Image(systemName: "info.circle.fill"),
                            title: "关于BabyMoney",
                            subtitle: "版本 1.0.0",
                            showArrow: true
                            )
                        
                            SettingRow(
                            icon: Image(systemName: "doc.text.fill"),
                            title: "用户协议",
                            subtitle: "查看用户服务条款",
                            showArrow: true
                            )
                        
                            SettingRow(
                            icon: Image(systemName: "shield.fill"),
                            title: "隐私政策",
                            subtitle: "了解我们如何保护你的数据",
                            showArrow: true
                            )
                        }
                    }
                    
                    // 退出登录
                    Button(action: {
                        showPasswordView = true
                    }) {
                        Text("退出登录")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(radius: 5)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                }
                
                // 底部导航栏
                BottomNavigationBar(selectedTab: .settings)
            }
        }
        .sheet(isPresented: $showPasswordView) {
            PasswordView()
        }
    }
}

// 用户信息卡片组件
struct UserInfoCard: View {
    let userName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
            
            HStack {
                // 用户头像
                ZStack {
                    Circle()
                        .fill(Color(hex: "FFEEEE"))
                        .frame(width: 80, height: 80)
                    
                    // 兔子头像
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF8585"))
                            .frame(width: 40, height: 40)
                        
                        // 兔子耳朵
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 8, height: 20)
                                .rotationEffect(Angle(degrees: -20))
                        }
                        .offset(x: -8, y: -20)
                        
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 8, height: 20)
                                .rotationEffect(Angle(degrees: 20))
                        }
                        .offset(x: 8, y: -20)
                    }
                }
                
                // 用户信息
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(userName)的账户")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
                    
                    Text("欢迎回来，\(userName)！")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                // 编辑按钮
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "FF8585"))
                    .padding()
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// 设置分组组件
struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // 分组标题
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "FF8585"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                
                Spacer()
            }
            
            // 分组内容背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 5)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .overlay {
                    VStack(spacing: 0) {
                        content()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                }
        }
    }
}

// 设置行项目组件
struct SettingRow<Content: View>: View {
    let icon: Image
    let title: String
    let subtitle: String
    let showArrow: Bool
    let rightContent: () -> Content
    
    init(
        icon: Image,
        title: String,
        subtitle: String,
        showArrow: Bool,
        @ViewBuilder rightContent: @escaping () -> Content = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showArrow = showArrow
        self.rightContent = rightContent
    }
    
    var body: some View {
        Button(action: {
            // 点击事件处理
        }) {
            HStack(spacing: 15) {
                // 图标
                icon
                    .foregroundColor(Color(hex: "FF8585"))
                    .frame(width: 30, height: 30)
                
                // 标题和副标题
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                // 右侧内容
                rightContent()
                
                // 箭头
                if showArrow {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "FF8585"))
                }
            }
            .padding(.vertical, 15)
        }
    }
}

// 底部导航栏组件
struct BottomNavigationBar: View {
    enum Tab: Int {
        case dashboard, reports, settings
    }
    
    let selectedTab: Tab
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(height: 56)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: -3)
            
            HStack {
                // 首页按钮
                TabButton(
                    icon: "house.fill",
                    label: "首页",
                    isSelected: selectedTab == .dashboard
                )
                
                // 报告按钮
                TabButton(
                    icon: "chart.bar.fill",
                    label: "报告",
                    isSelected: selectedTab == .reports
                )
                
                // 设置按钮
                TabButton(
                    icon: "gear.fill",
                    label: "设置",
                    isSelected: selectedTab == .settings
                )
            }
            .padding(.bottom, 8)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    // 标签按钮组件
    @ViewBuilder
    private func TabButton(icon: String, label: String, isSelected: Bool) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? Color(hex: "FF8585") : Color.gray)
                .font(.system(size: 20))
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(isSelected ? Color(hex: "FF8585") : Color.gray)
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    SettingsView()
}
