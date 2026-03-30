//
//  ContentView.swift
//  eatheal
//
//  Created by Yang Yang on 2026/3/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
            .environmentObject(AppViewModel())
    }
}

#Preview {
    ContentView()
}
