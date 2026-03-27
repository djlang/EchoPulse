//
//  TunerViewModel.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI
import Combine

class TunerViewModel: ObservableObject {
    @Published var selectedInstrument: InstrumentType?
    
    // 以后在这里添加音频处理逻辑：
    // @Published var currentPitch: Double = 0.0
    // @Published var noteName: String = "-"
    
    @Published var pitchOffset: Double = 0.0
    @Published var currentNote: String = "E"
    
    // 计算属性：将 -50...+50 映射到 -90°...+90° 的旋转角度
    var needleRotation: Double {
        return pitchOffset * 1.8 // 50 * 1.8 = 90度
    }
    
    // 根据精准度返回颜色
    var statusColor: Color {
        abs(pitchOffset) < 3 ? .green : (pitchOffset > 0 ? .red : .orange)
    }
}
