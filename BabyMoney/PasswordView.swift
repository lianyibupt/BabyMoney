import SwiftUI

struct PasswordView: View {
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(hex: "FFF5F5") // 浅粉色背景
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // 标题
                VStack(spacing: 8) {
                    Text("密码验证")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "FF8585"))
                        .padding(.top, 60)
                    
                    Text("请输入密码以保护你的账户安全")
                        .font(.system(size: 16))
                        .foregroundColor(Color.gray)
                }
                
                // 兔子图标
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(radius: 10)
                    
                    Circle()
                        .fill(Color(hex: "FFEEEE"))
                        .frame(width: 100, height: 100)
                    
                    // 兔子图标
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF8585"))
                            .frame(width: 50, height: 50)
                        
                        // 兔子耳朵
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 10, height: 30)
                                .rotationEffect(Angle(degrees: -20))
                        }
                        .offset(x: -10, y: -30)
                        
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "FF8585"))
                                .frame(width: 10, height: 30)
                                .rotationEffect(Angle(degrees: 20))
                        }
                        .offset(x: 10, y: -30)
                    }
                }
                
                // 密码输入区域
                VStack(spacing: 20) {
                    // 密码输入框
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(radius: 5)
                        
                        VStack(spacing: 15) {
                            // 密码显示点
                            HStack(spacing: 15) {
                                ForEach(0..<6) { index in
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(index < password.count ? Color(hex: "FF8585") : Color(hex: "E0E0E0"))
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .padding(.top, 10)
                            
                            // 隐藏的密码输入框
                            SecureField("", text: $password, onCommit: {
                                verifyPassword()
                            })
                                .hidden()
                                .onAppear {
                                    // 自动聚焦到密码输入
                                    UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                                }
                            
                            // 数字键盘提示
                            Text("请输入6位数字密码")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                        .padding(20)
                    }
                    .padding(.horizontal, 20)
                    
                    // 错误提示
                    if showError {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "FF6B6B"))
                            .padding(.horizontal, 20)
                    }
                }
                
                // 键盘提示
                Text("请使用系统键盘输入密码")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "FF8585"))
                    .padding(.top, 20)
            }
        }
        .onChange(of: password) { newValue in
            // 只允许输入数字
            let filtered = newValue.filter { $0.isNumber }
            if password != filtered {
                password = filtered
            }
            
            // 限制长度为6位
            if password.count > 6 {
                password = String(password.prefix(6))
            }
            
            // 自动验证
            if password.count == 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    verifyPassword()
                }
            }
            
            // 清除错误提示
            if showError && password.count < 6 {
                showError = false
            }
        }
    }
    
    private func verifyPassword() {
        // 简单的密码验证逻辑（实际应用中应该有更安全的验证方式）
        if password == "123456" {
            // 密码正确
            dismiss()
        } else {
            // 密码错误
            showError = true
            errorMessage = "密码错误，请重新输入"
            // 3秒后清除错误提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showError = false
            }
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
    PasswordView()
}