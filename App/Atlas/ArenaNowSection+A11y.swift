import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaNowSection.
/// Zero runs = ausência dita (goal 2026-07-17: contagem sempre visível).
/// Run → ArenaNowSection+A11yRun.swift

enum ArenaNowSectionA11y {
    static func spokenSection(running: Int, queuedSuites: Int) -> String {
        var parts: [String] = []
        if running > 0 { parts.append(running == 1 ? "1 medição rodando" : "\(running) medições rodando") }
        if queuedSuites > 0 { parts.append(queuedSuites == 1 ? "1 suíte na fila" : "\(queuedSuites) suítes na fila") }
        return parts.isEmpty ? "agora, nada medindo" : "agora, " + parts.joined(separator: ", ")
    }

    static func spokenRun(_ run: AtlasArenaLiveRun) -> String {
        ArenaNowSectionA11yRun.spokenRun(run)
    }
}
