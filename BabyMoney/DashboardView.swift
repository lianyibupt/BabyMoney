import SwiftUI
import SwiftData

// 简化的DashboardView
struct DashboardView: View {
    @State private var showingAddTransaction = false
    
    var body: some View {
        VStack {
            // 简单标题
            Text("智慧兔兔理财")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // 简单余额显示
            Text("余额: ¥0.00")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            // 主按钮
            Button("记一笔") {
                showingAddTransaction = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Spacer()
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
}

// 简化的AddTransactionView
struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var amount = ""
    
    var body: some View {
        VStack {
            Text("添加交易")
                .font(.title)
                .padding()
            
            Text("金额:")
                .padding(.leading)
            TextField("输入金额", text: $amount)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding()
            
            Spacer()
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Spacer()
                
                Button("确认") {
                    // 简单打印
                    print("添加金额: \(amount)")
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    DashboardView()
}