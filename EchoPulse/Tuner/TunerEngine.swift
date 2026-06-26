//
//  TunerEngine.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import AudioKit
import AudioKitEX
import SoundpipeAudioKit
import Foundation
import Combine
import AVFAudio

class TunerEngine: ObservableObject {
    private let engine = AudioEngine()
    private var silence: Fader?
    private var tracker: PitchTap?
    private var isRunning = false

    var onPitchDetected: ((Float, Float) -> Void)?

    func start() {
        guard !isRunning else { return }
        
        let session = AVAudioSession.sharedInstance()
        do {
            // 关键：使用 .playAndRecord 并禁用回声消除等处理，以获得原始频率
            try session.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .mixWithOthers])
            try session.setActive(true)
        } catch {
            print("AVAudioSession 配置失败: \(error)")
        }

        guard let input = engine.input else { 
            print("错误：无法获取麦克风输入节点")
            return 
        }
        
        // 1. 设置静音节点，防止由于麦克风采集到音箱输出导致的啸叫
        let fader = Fader(input)
        fader.gain = 0
        self.silence = fader
        engine.output = fader

        // 2. 初始化 PitchTap
        // 注意：在 input 节点上监听，不受后面 fader 增益的影响
        tracker = PitchTap(input) { [weak self] pitch, amp in
            // 降低阈值到 0.05，让轻微的拨弦也能被检测到
            if amp[0] > 0.05 {
                self?.onPitchDetected?(pitch[0], amp[0])
            }
        }

        // 3. 启动引擎
        do {
            try engine.start()
            tracker?.start()
            isRunning = true
            print("AudioKit 引擎已成功启动")
        } catch {
            print("AudioKit 引擎启动失败: \(error)")
        }
    }

    func stop() {
        guard isRunning else { return }
        tracker?.stop()
        engine.stop()
        isRunning = false
        print("AudioKit 引擎已停止")
    }
    
    // 权限检查逻辑保持不变...
    func checkMicPermission(completion: @escaping (Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
}
