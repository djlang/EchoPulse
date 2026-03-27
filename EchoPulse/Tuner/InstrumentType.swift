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
}
