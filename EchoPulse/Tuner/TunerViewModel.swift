//
//  TunerViewModel.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import SwiftUI
import Combine

class TunerViewModel: ObservableObject {
    let instrument: InstrumentType
    
    @Published var pitchOffset: Double = 0.0
    @Published var currentNote: String = ""
    @Published var selectedNoteKey: String = "" {
        didSet {
            // 切换弦时重置 UI 显示
            self.currentNote = selectedNoteKey
            // 切换弦时清空平滑缓存
            self.clearBuffer()
        }
    }
    
    private let engine = TunerEngine()
    
    // 平滑处理缓存 (加锁确保线程安全)
    private var offsetBuffer: [Double] = []
    private let maxBufferSize = 8 // 略微增大缓存，增加稳定性
    private let lock = NSLock()
    
    // 节流处理：避免主线程刷新过快
    private var lastUpdateTimestamp: TimeInterval = 0
    private let updateInterval: TimeInterval = 0.05 // 20 FPS
    
    let standardNotes: [String: Double]
    let tuningNoteKeys: [String]
    
    var needleRotation: Double {
        return pitchOffset * 1.8
    }
    
    var statusColor: Color {
        abs(pitchOffset) < 3 ? .green : (pitchOffset > 0 ? .red : .orange)
    }
    
    init(instrument: InstrumentType = .guitar) {
        self.instrument = instrument
        self.standardNotes = instrument.standardNotes
        self.tuningNoteKeys = instrument.tuningNoteKeys
        
        let initialNote = instrument.tuningNoteKeys.first ?? "-"
        self.currentNote = initialNote
        self.selectedNoteKey = initialNote
        
        engine.onPitchDetected = { [weak self] hz, amp in
            self?.analyze(frequency: Double(hz))
        }
    }
    
    private func clearBuffer() {
        lock.lock()
        offsetBuffer.removeAll()
        lock.unlock()
    }
    
    private func analyze(frequency: Double) {
        // 获取当前手动选中的那根弦的频率进行对比
        guard let targetFrequency = standardNotes[selectedNoteKey] else { return }
        
        // 打印原始数据用于调试
        print("DEBUG: 检测到频率: \(String(format: "%.2f", frequency)) Hz, 目标频率: \(targetFrequency) Hz")

        // 基础过滤逻辑：如果频率和目标频率偏差超过一个八度，大概率是泛音或背景噪音，忽略它
        // 1200 cents = 1 octave
        let rawOffset = 1200 * log2(frequency / targetFrequency)
        if abs(rawOffset) > 1200 { 
            print("DEBUG: 过滤掉可能的噪音/泛音: \(String(format: "%.2f", frequency)) Hz")
            return 
        }
        
        // 2. 线程安全更新缓存
        lock.lock()
        offsetBuffer.append(rawOffset)
        if offsetBuffer.count > maxBufferSize {
            offsetBuffer.removeFirst()
        }
        let smoothedOffset = offsetBuffer.reduce(0, +) / Double(offsetBuffer.count)
        lock.unlock()
        
        // 3. 节流更新 UI
        let now = CACurrentMediaTime()
        if now - lastUpdateTimestamp > updateInterval {
            lastUpdateTimestamp = now
            DispatchQueue.main.async {
                self.pitchOffset = max(-50, min(50, smoothedOffset))
                print("DEBUG: UI 更新偏差: \(String(format: "%.1f", self.pitchOffset)) cents")
                if self.currentNote != self.selectedNoteKey {
                    self.currentNote = self.selectedNoteKey
                }
            }
        }
    }

    func start() {
        engine.checkMicPermission { [weak self] granted in
            if granted {
                self?.engine.start()
            } else {
                print("用户拒绝了麦克风权限")
            }
        }
    }

    func stop() {
        engine.stop()
    }
}
