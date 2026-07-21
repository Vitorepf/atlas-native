import AtlasCore
import Foundation
import Observation

// IDLE-COMPRESS AtlasCodeWorkspaceModel fused

extension AtlasCodeWorkspaceModel {
    func scan(_ slugs: [String]) async {
        for slug in slugs where issuesBySlug[slug] == nil {
            guard let response = try? await client.getCodeViolations(repo: slug) else {
                failedSlugs.insert(slug)
                continue
            }
            failedSlugs.remove(slug)
            issuesBySlug[slug] = Self.group(response.violations)
            if let trunk = response.trunk { trunkBySlug[slug] = trunk }
        }
    }

    var headline: String {
        let all = issuesBySlug.values.flatMap { $0 }
        guard !all.isEmpty else {
            if !failedSlugs.isEmpty {
                let mudos = failedSlugs.count
                return mudos == 1 ? "1 repositório não respondeu" : "\(mudos) repositórios não responderam"
            }
            return issuesBySlug.isEmpty ? "lendo o workspace…" : "nada pede você"
        }
        var byRule: [String: AtlasCodeIssue] = [:]
        for issue in all {
            if let existing = byRule[issue.ruleId] {
                byRule[issue.ruleId] = AtlasCodeIssue(
                    ruleId: issue.ruleId,
                    count: existing.count + issue.count,
                    severity: existing.isSevere || issue.isSevere ? "high" : issue.severity,
                    oldestDays: [existing.oldestDays, issue.oldestDays].compactMap { $0 }.max()
                )
            } else {
                byRule[issue.ruleId] = issue
            }
        }
        let worst = byRule.values.sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
        return worst.first?.headline ?? "nada pede você"
    }

    var hasException: Bool { issuesBySlug.values.contains { !$0.isEmpty } }

    var scanState: AtlasCodeScanState {
        if hasException { return .violating }
        if !failedSlugs.isEmpty || issuesBySlug.isEmpty { return .unknown }
        return .clean
    }

    static func group(_ violations: [AtlasCodeViolation], now: Date = Date()) -> [AtlasCodeIssue] {
        var byRule: [String: (count: Int, severe: Bool, oldest: Int?)] = [:]
        for violation in violations {
            var entry = byRule[violation.ruleId] ?? (0, false, nil)
            entry.count += 1
            entry.severe = entry.severe || violation.severity == "high"
            if let since = violation.since, let date = AtlasCodeISO.date(from: since) {
                let days = max(0, Int(now.timeIntervalSince(date) / 86_400))
                entry.oldest = max(entry.oldest ?? 0, days)
            }
            byRule[violation.ruleId] = entry
        }
        return byRule
            .map { AtlasCodeIssue(ruleId: $0.key, count: $0.value.count, severity: $0.value.severe ? "high" : "medium", oldestDays: $0.value.oldest) }
            .sorted { ($0.isSevere ? 0 : 1, -$0.count) < ($1.isSevere ? 0 : 1, -$1.count) }
    }
}

enum AtlasCodeISO {
    static func date(from text: String) -> Date? {
        AtlasTime.date(text)
    }
}

@MainActor
@Observable
final class AtlasCodeWorkspaceModel {

    let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    var trunkBySlug: [String: String] = [:]
    var failedSlugs: Set<String> = []
    var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    func seedFromCache() {
        guard let cached = AtlasCodeWorkspaceCache.peek() else { return }
        workspace = cached
        phase = .loaded
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
            await scan(response.recents.map(\.slug))
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func loadStructure() async {
        if let cached = AtlasCodeWorkspaceCache.peek() {
            workspace = cached
            phase = .loaded
            return
        }
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            AtlasCodeWorkspaceCache.store(response)
            workspace = response
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }

    func toggle(_ folder: AtlasCodeFolder) async {
        if expandedFolders.contains(folder.slug) {
            expandedFolders.remove(folder.slug)
        } else {
            expandedFolders.insert(folder.slug)
            await scan(folder.repos.map(\.slug))
        }
    }

    func issues(for slug: String) -> [AtlasCodeIssue]? { issuesBySlug[slug] }

    func trunk(for slug: String) -> String? { trunkBySlug[slug] }
}
