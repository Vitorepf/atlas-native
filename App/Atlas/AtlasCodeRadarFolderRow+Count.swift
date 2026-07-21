import AtlasCore
import SwiftUI

// Contagem verificada — peel de AtlasCodeFolderRow.

extension AtlasCodeFolderRow {
    /// Só violações de repos já varridos — nil = ainda não medido, nunca conta.
    var verifiedExceptionCount: Int {
        folder.repos.reduce(0) { total, repo in
            guard let issues = issuesFor(repo.slug), !issues.isEmpty else { return total }
            return total + issues.reduce(0) { $0 + $1.count }
        }
    }
}
