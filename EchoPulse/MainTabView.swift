
//
//  MainTabView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TunerView()
                .tabItem {
                    Label("调音器", systemImage: "tuningfork")
                }
                .tag(0)
            
            MetronomeView()
                .tabItem {
                    Label("节拍器", systemImage: "metronome")
                }
                .tag(1)
        }
        .accentColor(.orange) // 设置一个充满活力的品牌色
    }
}


#Preview {
    MainTabView()
}
