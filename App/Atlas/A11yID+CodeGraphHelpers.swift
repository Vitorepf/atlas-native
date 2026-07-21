import Foundation

// Code graph helpers — peel de A11yID+CodeHelpers.

extension A11yID {
    static func codeCommit(hashPrefix: String) -> String { codeCommitPrefix + hashPrefix }
    static func codeGraphFilter(_ raw: String) -> String { codeGraphFilterPrefix + raw }
}
