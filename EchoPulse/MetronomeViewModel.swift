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
    
    enum TimeSignature: String, CaseIterable, Identifiable {
        case twoFour = "2/4"
        case threeFour = "3/4"
        case fourFour = "4/4"
        case sixEight = "6/8 (2)"
        
        var id: String { rawValue }
        
        var beatsPerBar: Int {
            switch self {
            case .twoFour: return 2
            case .threeFour: return 3
            case .fourFour: return 4
            case .sixEight:
                // Interpret 6/8 as 2 big beats per bar (strong-weak).
                return 2
            }
        }
        
        var accentBeatIndices: Set<Int> {
            // Basic: accent on the first beat of the bar.
            [0]
        }
    }

    @Published var bpm: Int = 120
    @Published var isRunning = false
    @Published var currentBeatIndex = 0 // 0...3 for 4/4
    @Published var timeSignature: TimeSignature = .fourFour {
        didSet {
            currentBeatIndex = 0
        }
    }
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
                let isAccent = self.timeSignature.accentBeatIndices.contains(self.currentBeatIndex)

                if self.soundEnabled {
                    self.engine.playClick(isAccent: isAccent)
                }

                // Advance beat
                self.currentBeatIndex = (self.currentBeatIndex + 1) % self.timeSignature.beatsPerBar

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
