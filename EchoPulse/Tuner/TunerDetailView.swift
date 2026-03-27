//
//  TunerDetailView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI
import Combine

struct TunerDetailView: View {
    let instrument: InstrumentType
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var detailVM = TunerViewModel()
    
    var body: some View {
        VStack {
            Spacer()
            // 这里就是我们下一阶段要开发的“仪表盘”位置
            
            TunerDashboardView(viewModel: detailVM)
            Spacer()
            
            // 测试滑杆（暂时用来模拟频率变化，方便调试 UI）
            VStack {
                Text("模拟频率偏差测试")
                    .font(.caption)
                Slider(value: $detailVM.pitchOffset, in: -50...50)
                    .accentColor(detailVM.statusColor)
            }
            .padding(40)
            

            // 底部弦指示器 (这里可以用 HStack 渲染吉他的 6 根弦)
            HStack(spacing: 12) {
                ForEach(["E2", "A2", "D3", "G3", "B3", "E4"], id: \.self) { note in
                    Text(note)
                        .font(.system(.body, design: .monospaced))
                        .frame(width: 45, height: 45)
                        .background(detailVM.currentNote == note.prefix(1) ? Color.orange : Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("正在调音")
        .navigationBarTitleDisplayMode(.inline)
    }
}
