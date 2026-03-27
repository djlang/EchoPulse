//
//  MetronomeView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//
import SwiftUI
struct MetronomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("120 BPM")
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                // 这里将来放置节拍控制逻辑
            }
            .navigationTitle("节拍器")
        }
    }
}
