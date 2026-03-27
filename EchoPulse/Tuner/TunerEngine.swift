//
//  TunerEngine.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import AudioKit
import AudioKitEX
import SoundpipeAudioKit // 提供高精度频率检测算法
import Foundation
import Combine

class TunerEngine: ObservableObject {
    private let engine = AudioEngine()
    private var mic: AudioEngine.InputNode?
    private var tappableNode: Fader? // 作为一个中间节点
    private var tracker: PitchTap?

    // 回调给 ViewModel：(频率Hz, 音量Amplitude)
    var onPitchDetected: ((Float, Float) -> Void)?

    func start() {
        guard let input = engine.input else { return }
        
        // 1. 设置输入并添加一个 Fader（音量设为0，防止回声啸叫）
        let fader = Fader(input)
        fader.gain = 0
        self.tappableNode = fader
        engine.output = fader

        // 2. 初始化 PitchTap
        tracker = PitchTap(fader) { [weak self] pitch, amp in
            // pitch[0] 是检测到的主频率，amp[0] 是音量
            if amp[0] > 0.1 { // 过滤背景噪音，只有声音够大才处理
                self?.onPitchDetected?(pitch[0], amp[0])
            }
        }

        // 3. 启动引擎
        do {
            try engine.start()
            tracker?.start()
        } catch {
            print("AudioKit 引擎启动失败: \(error)")
        }
    }

    func stop() {
        engine.stop()
        tracker?.stop()
    }
}
