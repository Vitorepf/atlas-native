import AtlasCore
import Observation

@MainActor
@Observable
final class AtlasCodeProvenanceModel {
    enum Phase: Equatable {
        case idle, loading, loaded(AtlasCodeProvenance), failed(String)
    }

    let client: AtlasClient
    let repo: String
    private(set) var phase: Phase = .idle

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func load(hash: String) async {
        phase = .loading
        do {
            phase = .loaded(try await client.getCodeProvenance(hash: hash, repo: repo))
        } catch {
            phase = .failed(String(describing: error))
        }
    }
}
