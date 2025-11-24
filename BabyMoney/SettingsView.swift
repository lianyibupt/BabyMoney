import SwiftUI
import LocalAuthentication
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @State private var showAuthentication = false
    @State private var isAuthenticated = false
    @State private var showAddUser = false
    @State private var showDeleteConfirm = false
    @State private var selectedUser: User?
    @State private var newUserName = ""
    @State private var newUserBalance: String = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var users: [User] = []
    
    var body: some View {
        NavigationView {
            List {
                // 安全设置部分
                Section(header: Text("安全设置")) {
                    Button(action: {
                        authenticateUser()
                    }) {
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.blue)
                            Text(isAuthenticated ? "已认证 - 可管理用户" : "家长认证")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // 用户管理部分
                Section(header: Text("用户管理")) {
                    if isAuthenticated {
                        Button(action: {
                            showAddUser = true
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .foregroundColor(.green)
                                Text("添加用户")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.primary)
                        
                        // 显示现有用户列表
                        ForEach(users) {
                            user in
                            HStack {
                                Text(user.name)
                                Spacer()
                                Text("余额: ¥\(user.balance)")
                                    .foregroundColor(.secondary)
                                Button(action: {
                                    selectedUser = user
                                    showDeleteConfirm = true
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    } else {
                        Text("请先进行家长认证")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 应用信息部分
                Section(header: Text("应用信息")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("BabyMoney Team")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddUser) {
                addUserSheet
            }
            .alert(isPresented: $showDeleteConfirm) {
                Alert(
                    title: Text("确认删除"),
                    message: Text("确定要删除用户 \(selectedUser?.name ?? "") 吗？此操作不可恢复。"),
                    primaryButton: .destructive(Text("删除")) {
                        if let user = selectedUser {
                            deleteUser(user)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("提示"), message: Text(alertMessage), dismissButton: .default(Text("确定")))
            }
            .onAppear {
                loadUsers()
            }
        }
    }
    
    private var addUserSheet: some View {
        NavigationView {
            Form {
                TextField("用户名", text: $newUserName)
                    .textFieldStyle(.roundedBorder)
                
                TextField("初始余额", text: $newUserBalance)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("添加用户")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        showAddUser = false
                        resetAddUserForm()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("添加") {
                        addNewUser()
                    }
                    .disabled(newUserName.isEmpty || newUserBalance.isEmpty)
                }
            }
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        // 检查设备是否支持生物识别认证
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "请进行家长认证以管理用户"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                        alertMessage = "认证成功"
                        showAlert = true
                    } else {
                        alertMessage = "认证失败，请重试"
                        showAlert = true
                    }
                }
            }
        } else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            // 如果设备不支持生物识别，使用密码认证
            let reason = "请输入密码进行家长认证"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        isAuthenticated = true
                        alertMessage = "认证成功"
                        showAlert = true
                    } else {
                        alertMessage = "认证失败，请重试"
                        showAlert = true
                    }
                }
            }
        } else {
            // 设备不支持认证
            alertMessage = "此设备不支持安全认证"
            showAlert = true
        }
    }
    
    private func loadUsers() {
        do {
            let descriptor = FetchDescriptor<User>()
            users = try modelContext.fetch(descriptor)
        } catch {
            print("加载用户数据失败: \(error)")
        }
    }
    
    private func addNewUser() {
        guard !newUserName.isEmpty, let balance = Double(newUserBalance) else {
            alertMessage = "请输入有效的用户名和余额"
            showAlert = true
            return
        }
        
        // 检查用户名是否已存在
        if users.contains(where: { $0.name == newUserName }) {
            alertMessage = "用户名已存在，请使用其他名称"
            showAlert = true
            return
        }
        
        let newUser = User(name: newUserName, balance: balance)
        modelContext.insert(newUser)
        
        do {
            try modelContext.save()
            alertMessage = "用户添加成功"
            showAlert = true
            showAddUser = false
            loadUsers()
            resetAddUserForm()
            
            // 发送通知，刷新用户列表
            NotificationCenter.default.post(name: Notification.Name("UserDataUpdated"), object: nil)
        } catch {
            alertMessage = "保存用户失败: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func deleteUser(_ user: User) {
        do {
            modelContext.delete(user)
            try modelContext.save()
            alertMessage = "用户删除成功"
            showAlert = true
            loadUsers()
            
            // 发送通知，刷新用户列表
            NotificationCenter.default.post(name: Notification.Name("UserDataUpdated"), object: nil)
        } catch {
            alertMessage = "删除用户失败: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func resetAddUserForm() {
        newUserName = ""
        newUserBalance = ""
    }
}