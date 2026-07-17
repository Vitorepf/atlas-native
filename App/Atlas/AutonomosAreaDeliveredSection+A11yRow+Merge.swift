import Foundation
import AtlasCore

// Merge spoken — peel de AutonomosAreaDeliveredSection+A11yRow.

extension AutonomosAreaDeliveredA11y {
    static func spokenRowMergeParts(_ cycle: AtlasAutonomosCycle) -> [String] {
        if cycle.mergePerformed, let hash = cycle.mergeHash.nonEmpty {
            return ["merge comprovado \(String(hash.prefix(8)))"]
        }
        return ["merge não publicado"]
    }
}
