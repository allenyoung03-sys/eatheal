//
//  eathealApp.swift
//  eatheal
//
//  Created by Yang Yang on 2026/3/29.
//

import SwiftUI

@main
struct eathealApp: App {
    @StateObject private var model = AppViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(model)
        }
    }
}
