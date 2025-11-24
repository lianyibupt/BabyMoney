import SwiftUI

// 简化的AI建议视图，移除所有依赖
struct AIAdviceView: View {
    var body: some View {
        VStack {
            Text("智慧兔兔理财助手")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("正在准备集成DeepSeek服务...")
                .padding()
        }
    }
}

#Preview {
    AIAdviceView()
}