import SwiftUI
import AtlasCore

// Helpers de entrega — peel de AutonomosAreaDeliveredSection+Row.

extension AutonomosAreaDeliveredSection {
    func openCommit(_ hash: String, repo: String) {
        guard let url = URL(string: "atlas://code/\(repo)?commit=\(hash)") else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        openURL(url)
    }

    func isSelfConstructionArea(_ area: AtlasAutonomosArea) -> Bool {
        area.repositoryNames.contains("atlas-native")
    }

    var selfConstructionFinding: AtlasAutonomosFinding? {
        model.backlog?.findings.items.first {
            $0.source == "native_constitution_scan"
                && (($0.ruleId?.isEmpty == false) || ($0.ruleText?.isEmpty == false))
        }
    }
}
