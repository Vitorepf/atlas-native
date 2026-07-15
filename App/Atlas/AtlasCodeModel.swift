import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeModel {
    enum Phase: Equatable {
        case idle, loading, loaded, failed(String)
    }

    let client: AtlasClient
    let repo: String
    private(set) var phase: Phase = .idle
    private(set) var graph: AtlasCodeGraphResponse?
    private(set) var violations: AtlasCodeViolationsResponse?

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    func load(before: String? = nil) async {
        phase = .loading
        do {
            graph = try await client.getCodeGraph(repo: repo, before: before)
            // A stale or unavailable scan must not hide a valid topology.
            violations = try? await client.getCodeViolations(repo: repo)
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }
}
