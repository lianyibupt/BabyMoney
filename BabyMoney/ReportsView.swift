import SwiftUI

struct ReportsView: View {
    var body: some View {
        VStack {
            Text("消费报告")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("正在准备集成DeepSeek服务...")
                .foregroundColor(.gray)
                .padding()
        }
        .padding()
    }
}

#Preview {
    ReportsView()
}