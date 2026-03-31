//
//  MainTabView.swift
//  eatheal
//

import SwiftUI

struct MainTabView: View {
    @State private var selected = 0

    var body: some View {
        TabView(selection: $selected) {
            DayPlanView()
                .tabItem {
                    Label("今天", systemImage: "calendar")
                }
                .tag(0)

            WeekOverviewView()
                .tabItem {
                    Label("每周", systemImage: "chart.bar.fill")
                }
                .tag(1)

            FoodLibraryView()
                .tabItem {
                    Label("食物", systemImage: "fork.knife")
                }
                .tag(2)

            TemplateManagementView()
                .tabItem {
                    Label("模板", systemImage: "bookmark.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(AppTheme.primaryGreen)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}
