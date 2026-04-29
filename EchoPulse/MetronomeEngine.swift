//
//  MetronomeEngine.swift
//  EchoPulse
//
//  Created by dj on 2026/4/29.
//

import AVFAudio
import Foundation

final class MetronomeEngine {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100

    private lazy var normalClick: AVAudioPCMBuffer? = makeClickBuffer(frequency: 1_200, duration: 0.02, gain: 0.35)
    private lazy var accentClick: AVAudioPCMBuffer? = makeClickBuffer(frequency: 1_600, duration: 0.02, gain: 0.55)

    private var isPrepared = false

    func prepare() throws {
        guard !isPrepared else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)

        engine.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        engine.connect(player, to: engine.mainMixerNode, format: format)

        try engine.start()
        player.play()

        isPrepared = true
    }

    func playClick(isAccent: Bool) {
        let buffer = isAccent ? accentClick : normalClick
        guard let buffer else { return }
        if !isPrepared {
            do {
                try prepare()
            } catch {
                return
            }
        }
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
    }

    func stop() {
        player.stop()
        engine.stop()
        isPrepared = false
    }
}

extension MetronomeEngine {
    private func makeClickBuffer(frequency: Double, duration: Double, gain: Float) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }

        buffer.frameLength = frameCount
        guard let channel = buffer.floatChannelData?[0] else { return nil }

        // A short decaying sine burst reads as a "click" without needing bundled audio assets.
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let envelope = exp(-t * 90) // fast decay
            let sample = sin(2 * .pi * frequency * t) * envelope
            channel[frame] = Float(sample) * gain
        }
        return buffer
    }
}

