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
    @Published var currentNote: String = "E2" //默认选中六弦
    @Published var selectedNoteKey: String = "E2"
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
        // 获取当前手动选中的那根弦的频率进行对比
        guard let targetFrequency = standardNotes[selectedNoteKey] else { return }
        
        let offset = 1200 * log2(frequency / targetFrequency)
        
        DispatchQueue.main.async {
            self.pitchOffset = max(-50, min(50, offset))
            // 更新当前音名显示
            self.currentNote = String(self.selectedNoteKey.prefix(1))
        }
    }

    func start() {
        engine.checkMicPermission { [weak self] granted in
            if granted {
                self?.engine.start()
            } else {
                // 这里可以弹出一个 Alert 提示用户去设置开启权限
                print("用户拒绝了麦克风权限")
            }
        }
    }
}
