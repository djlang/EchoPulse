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
                
                // 刻度线
                GaugeTicksShape(kind: .minor)
                    .stroke(Color.secondary.opacity(0.25), lineWidth: 2)
                GaugeTicksShape(kind: .major)
                    .stroke(Color.secondary.opacity(0.45), lineWidth: 2)
                
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
                Text(formattedOffset)
                    .fontWeight(.bold)
                Spacer()
                Text("+50")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(width: 320)
        }
    }
    
    private var formattedOffset: String {
        let value = Int(viewModel.pitchOffset.rounded())
        if value == 0 { return "0" }
        return value > 0 ? "+\(value)" : "\(value)"
    }
}

struct GaugeTicksShape: Shape {
    enum Kind {
        case minor
        case major
    }
    
    let kind: Kind
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        
        let values: [Int] = {
            switch kind {
            case .minor:
                return Array(stride(from: -50, through: 50, by: 10))
            case .major:
                return [-50, -25, 0, 25, 50]
            }
        }()
        
        for value in values {
            let tickLength: CGFloat = (kind == .major) ? 18 : 10
            let inset: CGFloat = 6
            
            // Map -50...+50 to 180°...0° (matching GaugeShape semicircle).
            let angleDegrees = 90 - (Double(value) * 1.8)
            let theta = angleDegrees * .pi / 180
            
            let outerRadius = radius - inset
            let innerRadius = outerRadius - tickLength
            
            let outer = CGPoint(
                x: center.x + CGFloat(cos(theta)) * outerRadius,
                y: center.y - CGFloat(sin(theta)) * outerRadius
            )
            let inner = CGPoint(
                x: center.x + CGFloat(cos(theta)) * innerRadius,
                y: center.y - CGFloat(sin(theta)) * innerRadius
            )
            
            path.move(to: outer)
            path.addLine(to: inner)
        }
        
        return path
    }
}

#Preview {
    let viewModel = TunerViewModel(instrument: .guitar)
    viewModel.pitchOffset = 0
    viewModel.selectedNoteKey = "E2"
    return TunerDashboardView(viewModel: viewModel)
        .padding()
}
