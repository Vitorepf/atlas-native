import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaNowSection (CICLO C residual honesty).
/// Sem runs = silêncio total; progresso falado só com casos publicados.
/// Run → ArenaNowSection+A11yRun.swift

enum ArenaNowSectionA11y {
    static func spokenSection(runCount: Int) -> String {
        let noun = runCount == 1 ? "medição ao vivo" : "medições ao vivo"
        return "agora, \(runCount) \(noun), seguir na Live Activity pendente de contrato dedicado para Arena"
    }

    static func spokenRun(_ run: AtlasArenaLiveRun) -> String {
        ArenaNowSectionA11yRun.spokenRun(run)
    }
}
