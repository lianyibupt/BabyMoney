import SwiftUI
import SwiftData

struct AIAdviceView: View {
    let user: User
    @Environment(\.modelContext) var modelContext
    @State private var advice: String = ""
    @State private var report: String = ""
    @State private var isLoading = false
    @State private var showReport = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 智慧兔兔头像和标题
                    HStack(alignment: .center, spacing: 16) {
                        Image(systemName: "brain.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color(hex: "#7B1FA2"))
                        
                        VStack(alignment: .leading) {
                            Text("智慧兔兔理财助手")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#7B1FA2"))
                            Text("为\(user.name)提供个性化建议")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                    
                    // 加载状态或建议内容
                    if isLoading {
                        ProgressView("正在思考中...")
                            .progressViewStyle(.circular)
                            .padding()
                    } else {
                        // 建议内容
                        Text(advice)
                            .font(.body)
                            .lineSpacing(8)
                            .padding()
                            .background(Color(hex: "#F8F8F8"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "#E0E0E0"), lineWidth: 1)
                            )
                    }
                    
                    // 魔法分析报告按钮
                    Button(action: {
                        generateReport()
                    }) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                            Text("获取魔法分析报告")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#9C27B0"))
                        .cornerRadius(12)
                        .padding(.vertical, 8)
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
            .navigationTitle("智慧兔兔")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        // 关闭视图的逻辑由调用方处理
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        refreshAdvice()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .sheet(isPresented: $showReport) {
                ReportDetailView(report: report, userName: user.name)
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("错误"), message: Text(errorMessage), dismissButton: .default(Text("确定")))
            }
            .onAppear {
                refreshAdvice()
            }
        }
    }
    
    private func refreshAdvice() {
        Task {
            isLoading = true
            do {
                let transactions = try await loadTransactions()
                advice = try await AIService.shared.getFinancialAdvice(for: user, transactions: transactions)
            } catch {
                errorMessage = "获取建议失败：\(error.localizedDescription)"
                showError = true
            } finally {
                isLoading = false
            }
        }
    }
    
    private func generateReport() {
        Task {
            isLoading = true
            do {
                let transactions = try await loadTransactions()
                report = try await AIService.shared.getConsumptionReport(for: user, transactions: transactions)
                showReport = true
            } catch {
                errorMessage = "生成报告失败：\(error.localizedDescription)"
                showError = true
            } finally {
                isLoading = false
            }
        }
    }
    
    private func loadTransactions() async throws -> [Transaction] {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                do {
                    let descriptor = FetchDescriptor<Transaction>(
                        predicate: #Predicate { $0.user?.id == user.id },
                        sortBy: [SortDescriptor(\Transaction.rawDate, order: .reverse)]
                    )
                    let transactions = try modelContext.fetch(descriptor)
                    continuation.resume(returning: transactions)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }


// 报告详情视图
struct ReportDetailView: View {
    let report: String
    let userName: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 报告标题和装饰
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color(hex: "#FFD700"))
                        
                        Text("魔法消费分析报告")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#9C27B0"))
                    }
                    .padding(.vertical)
                    
                    // 报告内容
                    Text(report)
                        .font(.body)
                        .lineSpacing(8)
                        .padding()
                        .background(Color(hex: "#F9F0FF"))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(hex: "#E1BEE7"), lineWidth: 1)
                        )
                }
                .padding()
            }
            .navigationTitle("分析报告")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {}
                }
            }
        }
    }
}


    }
}