//
//  BabyMoneyApp.swift
//  BabyMoney
//
//  Created by 易炼 on 2025/11/24.
//

import SwiftUI
import SwiftData

@main
struct BabyMoneyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            User.self,
            Transaction.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // 初始化默认数据
            DataManager.shared.initializeDefaultData(modelContext: container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
