import SwiftUI
import AtlasCore

// Finished spoken — peel de LiveNowRow+Spoken.

extension LiveNowRow {
    func spokenFinishedLabel(prefix: String) -> String {
        "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), concluído"
    }
}
