import Foundation

class AIService {
    static let shared = AIService()
    
    // 基础AI服务，后续将集成DeepSeek API
    private init() {}
    
    // 获取理财建议
    func getFinancialAdvice(for user: User, transactions: [Transaction]) async -> String {
        // 模拟API调用延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        
        return """
嗨，\(user.name)！我是你的智慧兔兔理财助手🐰

根据你的消费习惯和账户状况，我为你准备了一些个性化建议：

1. 继续保持良好的理财习惯！
2. 记得及时记录你的收入和支出
3. 设定一个小目标，培养储蓄意识

今日智慧小贴士：
制定一个小目标，比如每周存10元，积少成多，你会惊讶于自己的储蓄能力！
"""
    }
    
    // 获取消费分析报告
    func getConsumptionReport(for user: User, transactions: [Transaction]) async -> String {
        // 模拟API调用延迟
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
        
        return """
✨ 魔法消费分析报告 ✨

用户：\(user.name)
当前余额：¥\(String(format: "%.2f", user.balance))

📊 总体财务概览
- 总收入：¥0.00
- 总支出：¥0.00
- 净余额：¥0.00

💡 消费习惯洞察
- 继续保持良好的消费习惯！
- 记得定期记录你的交易

🌟 个性化建议
1. 建立3-6个月生活费的应急基金
2. 设置每周/每月消费限额
3. 记录每笔支出，培养消费意识
4. 制定小目标，如每周存10-20元

祝你理财顺利！🐰✨
"""
    }
}