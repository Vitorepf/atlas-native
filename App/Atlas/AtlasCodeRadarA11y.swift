import Foundation
import AtlasCore

// Radar folder/row spoken peels (IDLE-COMPRESS)

enum AtlasCodeFolderRowA11y {
    static func spokenFolder(
        name: String,
        repositoryCount: Int,
        verifiedExceptionCount: Int,
        isExpanded: Bool
    ) -> String {
        var parts = [name, spokenRepoCount(repositoryCount)]
        if verifiedExceptionCount > 0, let phrase = AtlasCodeFolderRowA11yExceptions.exceptionPhrase(verifiedExceptionCount) {
            parts.append(phrase)
        }
        if let expanded = spokenFolderExpanded(isExpanded) { parts.append(expanded) }
        return parts.joined(separator: ", ")
    }
}

enum AtlasCodeFolderRowA11yExceptions {
    static func exceptionPhrase(_ verifiedExceptionCount: Int) -> String? {
        guard verifiedExceptionCount > 0 else { return nil }
        return "\(verifiedExceptionCount) sem retorno\(verifiedExceptionCount == 1 ? "" : "s") verificado\(verifiedExceptionCount == 1 ? "" : "s")"
    }
}

extension AtlasCodeFolderRowA11y {
    static func spokenFolderExpanded(_ isExpanded: Bool) -> String? {
        isExpanded ? "expandida" : nil
    }
}

extension AtlasCodeFolderRowA11y {
    static func spokenHint(isExpanded: Bool) -> String {
        isExpanded ? "recolhe a pasta" : "expande a pasta"
    }
}

extension AtlasCodeFolderRowA11y {
    static func spokenRepoCount(_ repositoryCount: Int) -> String {
        repositoryCount == 1 ? "1 repositório" : "\(repositoryCount) repositórios"
    }
}

enum AtlasCodeRadarRowsA11y {
    static let repoHint = "abre o grafo do repositório"
}

extension AtlasCodeRadarRowsA11y {
    static func spokenRepoCommitAge(lastCommitAt: Int?) -> String? {
        guard let age = AtlasCodeAge.short(from: lastCommitAt) else { return nil }
        return "último commit \(age)"
    }
}
extension AtlasCodeRadarRowsA11y {
    static func spokenRepoFolder(folder: String?, showsFolder: Bool) -> [String] {
        guard showsFolder, let folder, !folder.isEmpty else { return [] }
        return ["pasta \(folder)"]
    }
}
extension AtlasCodeRadarRowsA11y {
    static func spokenRepo(
        name: String,
        folder: String?,
        showsFolder: Bool,
        issues: [AtlasCodeIssue]?,
        trunk: String?,
        lastCommitAt: Int?,
        isMute: Bool = false
    ) -> String {
        var parts = [name]
        parts.append(contentsOf: spokenRepoFolder(folder: folder, showsFolder: showsFolder))
        if isMute {
            parts.append(AtlasCodeRadarJudgment.muteSpoken)
        } else {
            parts.append(contentsOf: spokenRepoIssues(issues: issues, trunk: trunk))
        }
        if let age = spokenRepoCommitAge(lastCommitAt: lastCommitAt) {
            parts.append(age)
        }
        return parts.joined(separator: ", ")
    }
}
extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueFirst(
        issues: [AtlasCodeIssue],
        trunk: String?
    ) -> [String] {
        guard let first = issues.first else { return [] }
        var parts = [first.headline(trunk: trunk)]
        if first.isSevere { parts.append("alta severidade") }
        return parts
    }
}
extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssueMore(issues: [AtlasCodeIssue]) -> [String] {
        guard issues.count > 1 else { return [] }
        let more = issues.count - 1
        return ["mais \(more) sem retorno\(more == 1 ? "" : "s")"]
    }
}
extension AtlasCodeRadarRowsA11y {
    static func spokenRepoIssues(
        issues: [AtlasCodeIssue]?,
        trunk: String?
    ) -> [String] {
        guard let issues, !issues.isEmpty else { return [] }
        return spokenRepoIssueFirst(issues: issues, trunk: trunk)
            + spokenRepoIssueMore(issues: issues)
    }
}
