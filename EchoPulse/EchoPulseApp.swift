//
//  EchoPulseApp.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI

@main
struct EchoPulseApp: App {
    init() {
        // 禁止自动进入休眠，方便用户调音时不用一直点屏幕
        UIApplication.shared.isIdleTimerDisabled = true
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
