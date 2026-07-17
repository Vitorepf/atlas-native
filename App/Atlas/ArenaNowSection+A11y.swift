import Foundation
import AtlasCore

/// Spoken labels — peel de ArenaNowSection (CICLO C residual honesty).
/// Sem runs = silêncio total; progresso falado só com casos publicados.

enum ArenaNowSectionA11y {
    static func spokenSection(runCount: Int) -> String {
        let noun = runCount == 1 ? "medição ao vivo" : "medições ao vivo"
        return "agora, \(runCount) \(noun), seguir na Live Activity pendente de contrato dedicado para Arena"
    }

    static func spokenRun(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT ?? "braço desconhecido"
        var parts = [run.suite, run.engineDisplayName, arm, run.status.displayPT]
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            parts.append("\(done) de \(total) casos")
        }
        return parts.joined(separator: ", ")
    }
}
