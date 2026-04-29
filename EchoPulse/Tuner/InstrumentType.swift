//
//  InstrumentType.swift
//  EchoPulse
//
//  Created by dj on 2026/3/27.
//

import Foundation

enum InstrumentType: String, CaseIterable, Identifiable {
    case guitar = "吉他"
    case ukulele = "尤克里里"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .guitar: return "guitars.fill"
        case .ukulele: return "music.note"
        }
    }

    var tuningNoteKeys: [String] {
        switch self {
        case .guitar:
            return ["E2", "A2", "D3", "G3", "B3", "E4"]
        case .ukulele:
            // Standard re-entrant tuning (high G)
            return ["G4", "C4", "E4", "A4"]
        }
    }

    var standardNotes: [String: Double] {
        switch self {
        case .guitar:
            return [
                "E2": 82.41,
                "A2": 110.00,
                "D3": 146.83,
                "G3": 196.00,
                "B3": 246.94,
                "E4": 329.63
            ]
        case .ukulele:
            return [
                "G4": 392.00,
                "C4": 261.63,
                "E4": 329.63,
                "A4": 440.00
            ]
        }
    }
}
