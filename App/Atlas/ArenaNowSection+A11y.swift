import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaNowSection.
/// Zero runs = ausência dita (goal 2026-07-17: contagem sempre visível).
/// Run → ArenaNowSection+A11yRun.swift

enum ArenaNowSectionA11y {
    static func spokenSection(runCount: Int) -> String {
        guard runCount > 0 else { return "agora, nenhuma medição em andamento" }
        let noun = runCount == 1 ? "medição ao vivo" : "medições ao vivo"
        return "agora, \(runCount) \(noun)"
    }

    static func spokenRun(_ run: AtlasArenaLiveRun) -> String {
        ArenaNowSectionA11yRun.spokenRun(run)
    }
}
