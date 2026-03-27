//
//  TunerDashboardView.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI
import Combine

struct TunerDashboardView: View {
    @ObservedObject var viewModel: TunerViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. 顶部音名显示
            Text(viewModel.currentNote)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .foregroundColor(viewModel.statusColor)
                .shadow(color: viewModel.statusColor.opacity(0.3), radius: 10)

            // 2. 仪表盘主体
            ZStack {
                // 背景弧线
                GaugeShape()
                    .stroke(Color.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(height: 150)
                
                // 刻度线 (简单的中心点)
                Rectangle()
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 2, height: 30)
                    .offset(y: -75) // 指向正上方 0 位置
                
                // 3. 动态指针
                Capsule()
                    .fill(viewModel.statusColor)
                    .frame(width: 4, height: 120)
                    .offset(y: -60) // 将锚点移至底部
                    .rotationEffect(.degrees(viewModel.needleRotation), anchor: .bottom)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.pitchOffset)
            }
            .frame(width: 300, height: 150)
            
            // 4. 数值显示
            HStack {
                Text("-50")
                Spacer()
                Text("0")
                    .fontWeight(.bold)
                Spacer()
                Text("+50")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(width: 320)
        }
    }
}
