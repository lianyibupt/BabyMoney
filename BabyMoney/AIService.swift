import Foundation
import SwiftData

class AIService {
    static let shared = AIService()
    
    // 模拟Gemini AI服务，实际项目中需要集成真实的API
    private init() {}
    
    // 获取理财建议
    func getFinancialAdvice(for user: User, transactions: [Transaction]) async -> String {
        // 模拟API调用延迟
        await Task.sleep(1_000_000_000) // 1秒
        
        // 根据用户数据生成模拟建议
        let advice = generateAdvice(for: user, transactions: transactions)
        return advice
    }
    
    // 获取消费分析报告
    func getConsumptionReport(for user: User, transactions: [Transaction]) async -> String {
        // 模拟API调用延迟
        await Task.sleep(1_500_000_000) // 1.5秒
        
        // 根据交易数据生成模拟分析报告
        let report = generateConsumptionReport(for: user, transactions: transactions)
        return report
    }
    
    // 生成理财建议
    private func generateAdvice(for user: User, transactions: [Transaction]) -> String {
        let recentExpenses = transactions
            .filter { $0.type == .expense }
            .sorted(by: { $0.rawDate > $1.rawDate })
            .prefix(5)
        
        let recentIncome = transactions
            .filter { $0.type == .income }
            .sorted(by: { $0.rawDate > $1.rawDate })
            .prefix(3)
        
        var advice = """
嗨，\(user.name)！我是你的智慧兔兔理财助手🐰

根据你的消费习惯和账户状况，我为你准备了一些个性化建议：

"""
        
        // 根据余额给出建议
        if user.balance < 100 {
            advice += "1. 你的余额较少，建议控制非必要开支，积累一些应急资金哦~\n"
        } else if user.balance > 1000 {
            advice += "1. 你的余额很健康！可以考虑制定更有挑战性的储蓄目标。\n"
        } else {
            advice += "1. 你的余额适中，继续保持良好的理财习惯！\n"
        }
        
        // 分析最近的消费
        if !recentExpenses.isEmpty {
            let expenseCategories = recentExpenses.map { $0.category?.name ?? "其他" }
            let categoryCounts = Dictionary(grouping: expenseCategories, by: { $0 })
                .mapValues { $0.count }
                .sorted { $0.value > $1.value }
            
            if let topCategory = categoryCounts.first {
                advice += "2. 我注意到你最近在\(topCategory.key)方面的支出较多，共\(topCategory.value)次。\n"
            }
        }
        
        // 分析收入情况
        if recentIncome.isEmpty {
            advice += "3. 最近没有收入记录，记得及时记录你的零花钱或红包哦！\n"
        } else {
            let totalRecentIncome = recentIncome.reduce(0) { $0 + $1.amount }
            advice += "3. 你最近有\(recentIncome.count)笔收入，共\(totalRecentIncome)元，太棒了！\n"
        }
        
        // 鼓励性建议
        advice += """

今日智慧小贴士：
制定一个小目标，比如每周存10元，积少成多，你会惊讶于自己的储蓄能力！

需要更详细的分析吗？点击下方的"魔法分析报告"按钮查看完整分析哦！
"""
        
        return advice
    }
    
    // 生成消费分析报告
    private func generateConsumptionReport(for user: User, transactions: [Transaction]) -> String {
        // 计算总收支
        let totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let totalExpense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        // 按类别统计消费
        let categoryExpenses = Dictionary(grouping: transactions.filter { $0.type == .expense }, by: { $0.category?.name ?? "其他" })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
            .sorted { $0.value > $1.value }
        
        // 最近交易统计
        let recentMonthTransactions = transactions.filter { Calendar.current.isDate($0.rawDate, equalTo: Date(), toGranularity: .month) }
        let recentMonthIncome = recentMonthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let recentMonthExpense = recentMonthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        
        var report = """
✨ 魔法消费分析报告 ✨

用户：\(user.name)
当前余额：¥\(String(format: "%.2f", user.balance))

📊 总体财务概览
- 总收入：¥\(String(format: "%.2f", totalIncome))
- 总支出：¥\(String(format: "%.2f", totalExpense))
- 净余额：¥\(String(format: "%.2f", totalIncome - totalExpense))

"""
        
        // 本月收支
        if !recentMonthTransactions.isEmpty {
            report += """
📅 本月收支情况
- 本月收入：¥\(String(format: "%.2f", recentMonthIncome))
- 本月支出：¥\(String(format: "%.2f", recentMonthExpense))

"""
        }
        
        // 消费类别分析
        if !categoryExpenses.isEmpty {
            report += "🛍️ 消费类别分析\n"
            for (category, amount) in categoryExpenses.prefix(5) {
                let percentage = (amount / totalExpense) * 100
                report += "- \(category)：¥\(String(format: "%.2f", amount)) (\(String(format: "%.1f", percentage))%)\n"
            }
            report += "\n"
        }
        
        // 消费习惯建议
        report += "💡 消费习惯洞察\n"
        
        if totalExpense > totalIncome * 0.8 {
            report += "- 你的支出占收入比例较高，建议适当控制消费节奏\n"
        }
        
        if let topCategory = categoryExpenses.first, topCategory.value > totalExpense * 0.4 {
            report += "- 在\(topCategory.key)方面的支出占比较大，可以考虑优化这部分消费\n"
        }
        
        if user.balance > totalIncome * 0.5 {
            report += "- 你有良好的储蓄习惯，继续保持！\n"
        }
        
        // AI预测和建议
        report += """

🔮 未来消费预测
基于你的消费模式，预计你每月平均支出约为¥\(String(format: "%.2f", totalExpense / max(1, Double(transactions.count/2))))。

🌟 个性化建议
1. 建立3-6个月生活费的应急基金
2. 设置每周/每月消费限额
3. 记录每笔支出，培养消费意识
4. 制定小目标，如每周存10-20元

记住，理财是一场马拉松，不是短跑！每一个小习惯的改变，都会带来巨大的进步。

祝你理财顺利！🐰✨
"""
        
        return report
    }
}