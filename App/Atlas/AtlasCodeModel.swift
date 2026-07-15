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

    init(client: AtlasClient, repo: String = "atlas-server") {
        self.client = client
        self.repo = repo
    }

    func load(before: String? = nil) async {
        phase = .loading
        do {
            graph = try await client.getCodeGraph(repo: repo, before: before)
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }
}
