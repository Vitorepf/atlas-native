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
    var issuesBySlug: [String: [AtlasCodeIssue]] = [:]
    var trunkBySlug: [String: String] = [:]
    var failedSlugs: Set<String> = []
    var expandedFolders: Set<String> = []

    init(client: AtlasClient) {
        self.client = client
    }

    /// Hidrata na hora a partir do cache — picker sem frame de loading.
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

    /// Só a frota (pastas/repos) — sem scan de violações.
    /// Cache quente → instantâneo no picker do grafo.
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
