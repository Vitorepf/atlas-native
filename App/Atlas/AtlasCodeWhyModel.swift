import Foundation
import Observation
import AtlasCore

@MainActor
@Observable
final class AtlasCodeWhyModel {
    private let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var why: AtlasCodeWhy?
    private(set) var message: String?
    private var wanted: String?

    init(client: AtlasClient) {
        self.client = client
    }

    func load(repo: String, file: String) async {
        let key = "\(repo)\n\(file)"
        wanted = key
        phase = .loading
        message = nil
        do {
            let response = try await client.getCodeWhy(repo: repo, file: file)
            guard wanted == key else { return }
            why = response
            phase = .loaded
        } catch {
            guard wanted == key else { return }
            message = String(describing: error)
            phase = .failed(message ?? "falha desconhecida")
        }
    }
}
