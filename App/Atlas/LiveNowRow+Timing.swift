import SwiftUI
import AtlasCore

/// Relógio, timing e acessibilidade temporal — peel de LiveNowRow.
/// Clock → LiveNowRow+Clock.swift
/// Line → LiveNowRow+TimingLine.swift
extension LiveNowRow {
    var timingWord: String {
        switch session.timing {
        case .running: return "em execução"
        case .paused: return "pausado"
        case .finished: return "concluído"
        }
    }

    var timingColor: Color {
        switch session.timing {
        case .running: return AtlasTheme.accent
        case .paused: return AtlasTheme.textTertiary
        case .finished: return AtlasTheme.textSecondary
        }
    }
}
