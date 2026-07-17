import Foundation
import AtlasCore

/// Run spoken — peel de ArenaNowSection+A11y.

enum ArenaNowSectionA11yRun {
    static func spokenRun(_ run: AtlasArenaLiveRun) -> String {
        let arm = run.arm?.labelPT ?? "braço desconhecido"
        var parts = [run.suite, run.engineDisplayName, arm, run.status.displayPT]
        if let done = run.casesDone, let total = run.casesTotal, total > 0 {
            parts.append("\(done) de \(total) casos")
        }
        return parts.joined(separator: ", ")
    }
}
