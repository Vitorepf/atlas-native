import Foundation
import AtlasCore

// Decided action spoken — peel de ChangeReviewSections+A11yToast.

extension ChangeReviewSectionsA11y {
    static func spokenDecidedAction(_ action: AtlasTraceChangeReview.OperatorAction) -> String {
        var parts = [action.action == .accept ? "aceito" : "rejeitado"]
        if let at = action.actedAt?.nonEmpty { parts.append(at) }
        return parts.joined(separator: ", ")
    }
}
