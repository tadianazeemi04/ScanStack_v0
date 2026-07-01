//
//  ScanStack_v0App.swift
//  ScanStack_v0
//
//  Created by Tadian Ahmad Azeemi on 14/05/2026.
//

import SwiftUI
import CoreData

@main
struct ScanStack_v0App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            StartupView()
        }
    }
}
