import AtlasCore
import Observation
import Foundation

/// M3 · Modelo do workspace do radar de Código.
///
/// Modelo mental correto: `Atlas/` e `blackink/` são PASTAS de produto que
/// contêm repositórios; pasta não é repositório quebrado. A tela mostra
/// **Recentes** (o trabalho vivo — atalho, não cópia) e **Pastas** (a verdade
/// completa). Scan/headline: AtlasCodeWorkspaceModel+Scan.swift
@MainActor
@Observable
final class AtlasCodeWorkspaceModel {

    let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var workspace: AtlasCodeWorkspaceResponse?
    private(set) var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    private(set) var trunkBySlug: [String: String] = [:]
    private(set) var failedSlugs: Set<String> = []
    private(set) var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    func load() async {
        phase = .loading
        do {
            let response = try await client.getCodeWorkspace()
            workspace = response
            phase = .loaded
            await scan(response.recents.map(\.slug))
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
