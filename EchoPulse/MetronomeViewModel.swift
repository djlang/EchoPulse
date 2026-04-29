//
//  MetronomeViewModel.swift
//  EchoPulse
//
//  Created by dj on 2026/4/29.
//

import Foundation
import Combine

@MainActor
final class MetronomeViewModel: ObservableObject {
    enum Style: String, CaseIterable, Identifiable {
        case pendulum = "摆针"
        case flash = "闪烁"

        var id: String { rawValue }
    }

    @Published var bpm: Int = 120
    @Published var isRunning = false
    @Published var currentBeatIndex = 0 // 0...3 for 4/4
    @Published var style: Style = .pendulum
    @Published var soundEnabled = true

    private let engine = MetronomeEngine()
    private var tickTask: Task<Void, Never>?

    var beatDurationSeconds: Double {
        60.0 / Double(bpm)
    }

    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        tickTask?.cancel()
        tickTask = Task { [weak self] in
            guard let self else { return }

            let clock = ContinuousClock()
            var nextTick = clock.now

            while !Task.isCancelled {
                let isAccent = (self.currentBeatIndex == 0)

                if self.soundEnabled {
                    self.engine.playClick(isAccent: isAccent)
                }

                // Advance beat (4/4 only for now)
                self.currentBeatIndex = (self.currentBeatIndex + 1) % 4

                nextTick = nextTick.advanced(by: .milliseconds(Int(self.beatDurationSeconds * 1000)))
                try? await clock.sleep(until: nextTick, tolerance: .milliseconds(5))
            }
        }
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        tickTask?.cancel()
        tickTask = nil
        engine.stop()
        currentBeatIndex = 0
    }
}
