import Foundation
import AtlasCore

// Single test spoken — peel de ChangeReviewSections+A11yDecided.

extension ChangeReviewSectionsA11y {
    static func spokenTest(_ test: AtlasTraceChangeReview.TestRun) -> String {
        "\(test.command ?? "teste"), status \(test.status)"
    }
}
