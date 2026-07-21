import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive workspace-picker sheet face (WAVE-097).
enum WorkspacePickerFace: Equatable {
    case loading
    case failed
    case empty
    case list(Int)
    case miss

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .list(let n): return "list(\(n))"
        case .miss: return "miss"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "lendo repositórios"
        case .failed: return "Mac não respondeu"
        case .empty: return "nenhum repositório"
        case .list(let n):
            let noun = n == 1 ? "repositório" : "repositórios"
            return "\(n) \(noun)"
        case .miss: return "nenhum repositório com a busca"
        }
    }
}

// MARK: - Judgment

/// Pure workspace-picker grammar — face · rank · filter · spoken · pack.
enum WorkspacePickerJudgment {

    static let loadingCopy = "lendo os repositórios do Mac…"
    static let failedHeadline = "O Mac não respondeu."
    static let retryLabel = "Tentar de novo"
    static let noRepoLabel = "sem repositório"
    static let noRepoHint = "conversa geral com o Atlas, sem projeto"
    static let noRepoTitle = "Sem repositório"
    static let noRepoSubtitle = "conversar ou pesquisar, sem projeto"
    static let reposCaption = "REPOSITÓRIOS"
    static let searchPrompt = "Buscar repositórios"
    static let rowHint = "abre o workspace deste repositório"
    static let closeLabel = "Fechar"

    // MARK: Face

    static func face(
        phase: LoadPhase,
        repoCount: Int,
        query: String
    ) -> WorkspacePickerFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed:
            return .failed
        case .loaded:
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if repoCount <= 0 {
                return trimmed.isEmpty ? .empty : .miss
            }
            return .list(repoCount)
        }
    }

    // MARK: Rank / filter

    /// Dedupe by slug; lastCommit desc; name ASC stable.
    static func rank(_ repos: [AtlasCodeRepoRef]) -> [AtlasCodeRepoRef] {
        var seen = Set<String>()
        let unique = repos.filter { seen.insert($0.slug).inserted }
        return unique.enumerated().sorted { lhs, rhs in
            switch (lhs.element.lastCommitAt, rhs.element.lastCommitAt) {
            case let (x?, y?):
                if x != y { return x > y }
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                break
            }
            let nameCmp = lhs.element.name.localizedCaseInsensitiveCompare(rhs.element.name)
            if nameCmp != .orderedSame { return nameCmp == .orderedAscending }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func filter(_ repos: [AtlasCodeRepoRef], query: String) -> [AtlasCodeRepoRef] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return repos }
        return repos.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || ($0.folder?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
    }

    static func repos(
        from workspace: AtlasCodeWorkspaceResponse?,
        query: String
    ) -> [AtlasCodeRepoRef] {
        guard let ws = workspace else { return [] }
        let all = ws.folders.flatMap(\.repos) + ws.loose + ws.recents
        return filter(rank(all), query: query)
    }

    // MARK: Spoken

    static func spokenLoading() -> String { loadingCopy }

    static func spokenFailed() -> String { failedHeadline }

    static func spokenNoRepo() -> String { noRepoLabel }

    static func spokenRow(folder: String?, name: String) -> String {
        if let folder, !folder.isEmpty {
            return "\(folder), \(name)"
        }
        return name
    }

    static func spokenRow(_ repo: AtlasCodeRepoRef) -> String {
        spokenRow(folder: repo.folder, name: repo.name)
    }

    static func spokenSheet(face: WorkspacePickerFace, title: String) -> String {
        "\(title), \(face.spokenFace)"
    }

    // MARK: Pack

    static func packFacts(
        phase: LoadPhase,
        repoCount: Int,
        query: String,
        showsNoRepo: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, repoCount: repoCount, query: query)
        facts.append("workspace_picker_face: \(face.productWord)")
        facts.append("workspace_picker_count: \(repoCount)")
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            facts.append("workspace_picker_query: \(trimmed)")
        }
        if showsNoRepo {
            facts.append("workspace_picker_no_repo_row: true")
        }
        switch face {
        case .loading:
            absences.append("repositórios ainda carregando do Mac")
        case .failed:
            absences.append("Mac não respondeu ao listar repositórios")
        case .empty:
            absences.append("nenhum repositório no workspace publicado")
        case .miss:
            absences.append("busca sem repositórios")
        case .list:
            break
        }
        return (facts, absences)
    }
}
