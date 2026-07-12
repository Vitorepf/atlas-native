import SwiftUI
import AtlasCore

// A ponte entre o AtlasCore (lógica/rede pura) e a UI. @Observable + @MainActor:
// o estado vive na main thread, as chamadas de rede vão pro actor AtlasClient.
// Host/porta/token vêm do Info.plist (populados pelo Config.xcconfig / Secrets),
// espelhando como o app RN lê `expo extra.atlas`.
@MainActor
@Observable
final class AtlasSession {
    enum Phase: Equatable {
        case idle, loading, loaded
        case failed(String)
    }

    var phase: Phase = .idle
    var threads: [AtlasAiThread] = []

    let host: String
    let hasToken: Bool
    private let client: AtlasClient

    init() {
        let info = Bundle.main.infoDictionary ?? [:]
        let host = (info["ATLAS_HOST"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? "127.0.0.1"
        let port = Int((info["ATLAS_PORT"] as? String) ?? "3737") ?? 3737
        let token = (info["ATLAS_TOKEN"] as? String) ?? ""
        self.host = host
        self.hasToken = !token.isEmpty
        self.client = AtlasClient(config: AtlasConfig(host: host, port: port, token: token))
    }

    func loadThreads() async {
        phase = .loading
        do {
            let response = try await client.listAiThreads(light: true, limit: 30)
            threads = response.threads
            phase = .loaded
        } catch {
            phase = .failed(String(describing: error))
        }
    }
}
