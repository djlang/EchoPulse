//
//  GaugeShape.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI

struct GaugeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // 画一个 180 度的半圆弧
        path.addArc(center: CGPoint(x: rect.midX, y: rect.height),
                    radius: rect.width / 2,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false)
        return path
    }
}
