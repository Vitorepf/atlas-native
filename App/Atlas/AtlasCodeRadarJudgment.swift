import Foundation
import AtlasCore

// WAVE-024 — fleet judgment helpers (presentation-only; never invent scan totals).

enum AtlasCodeRadarJudgment {
    /// Issues-first when scan data exists; otherwise wire order (honesty).
    static func sortedForJudgment(
        _ repos: [AtlasCodeRepoRef],
        issuesBySlug: [String: [AtlasCodeIssue]],
        failedSlugs: Set<String>
    ) -> [AtlasCodeRepoRef] {
        guard !issuesBySlug.isEmpty || !failedSlugs.isEmpty else { return repos }

        func issueCount(_ slug: String) -> Int {
            issuesBySlug[slug]?.count ?? 0
        }

        func hasIssues(_ slug: String) -> Bool {
            guard let issues = issuesBySlug[slug] else { return false }
            return !issues.isEmpty
        }

        return repos.enumerated().sorted { lhs, rhs in
            let l = lhs.element.slug
            let r = rhs.element.slug
            let lIssues = hasIssues(l)
            let rIssues = hasIssues(r)
            if lIssues != rIssues { return lIssues && !rIssues }
            let lc = issueCount(l)
            let rc = issueCount(r)
            if lc != rc { return lc > rc }
            // Mute never ranks as clean priority — after issues, stable wire index.
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func issueSignalCount(_ issues: [AtlasCodeIssue]?) -> Int {
        issues?.count ?? 0
    }

    /// Top attention subjects for pack — real counts only.
    static func topAttention(
        issuesBySlug: [String: [AtlasCodeIssue]],
        limit: Int = 5
    ) -> [(slug: String, count: Int)] {
        issuesBySlug
            .compactMap { slug, issues -> (String, Int)? in
                guard !issues.isEmpty else { return nil }
                return (slug, issues.count)
            }
            .sorted { lhs, rhs in
                if lhs.1 != rhs.1 { return lhs.1 > rhs.1 }
                return lhs.0 < rhs.0
            }
            .prefix(limit)
            .map { (slug: $0.0, count: $0.1) }
    }

    static let muteBadgeLabel = "mudo"
    static let muteSpoken = "não respondeu ao scan"
}
