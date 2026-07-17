import Foundation

// Review council A11yIDs — peel de A11yID+Review.

extension A11yID {
    static let reviewCouncil = "review-council"
    static let reviewCouncilMemberPrefix = "review-council-member-"
    static func reviewCouncilMember(_ provider: String) -> String {
        reviewCouncilMemberPrefix + provider.lowercased()
    }
}
