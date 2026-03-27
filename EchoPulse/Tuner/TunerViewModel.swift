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
    
    private let engine = TunerEngine()
    
    // 标准音频率表 (简化版)
    let standardNotes = [
        "E2": 82.41, "A2": 110.00, "D3": 146.83,
        "G3": 196.00, "B3": 246.94, "E4": 329.63
    ]
    
    // 计算属性：将 -50...+50 映射到 -90°...+90° 的旋转角度
    var needleRotation: Double {
        return pitchOffset * 1.8 // 50 * 1.8 = 90度
    }
    
    // 根据精准度返回颜色
    var statusColor: Color {
        abs(pitchOffset) < 3 ? .green : (pitchOffset > 0 ? .red : .orange)
    }
    
    init() {
        engine.onPitchDetected = { [weak self] hz, amp in
            DispatchQueue.main.async {
                self?.analyze(frequency: Double(hz))
            }
        }
    }
    
    private func analyze(frequency: Double) {
        // 1. 寻找最接近的标准弦频率
        guard let closest = standardNotes.min(by: { abs($0.value - frequency) < abs($1.value - frequency) }) else { return }
        
        // 2. 计算音分偏移
        // Formula: 1200 * log2(f1 / f2)
        let offset = 1200 * log2(frequency / closest.value)
        
        // 3. 更新 UI (限制在 -50 到 50 之间)
        self.pitchOffset = max(-50, min(50, offset))
        self.currentNote = String(closest.key.prefix(1)) // 只显示音名 E, A, D...
    }

    func start() { engine.start() }
}
