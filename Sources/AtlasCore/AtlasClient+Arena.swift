import Foundation

/// Start/enqueue + AtlasClient Arena methods — DTOs de leitura ficam em
/// `AtlasArena.swift`; mutação e transporte vivem aqui.
public extension AtlasClient {
    func getArenaComposite() async throws -> AtlasArenaComposite {
        try await get(AtlasRoute.arenaComposite)
    }

    func getArenaScoreboard() async throws -> AtlasArenaScoreboard {
        try await get(AtlasRoute.arenaScoreboard)
    }

    func getArenaCapabilities(engine: String) async throws -> AtlasArenaCapabilities {
        try await get(AtlasRoute.arenaCapabilities(engine: engine))
    }

    func getArenaLiveRuns() async throws -> AtlasArenaLiveRuns {
        try await get(AtlasRoute.arenaLiveRuns)
    }

    func startArenaRuns(input: AtlasArenaStartInput) async throws -> AtlasArenaStartReceipt {
        guard input.isLocallyValidForSubmission else { throw AtlasArenaClientError.invalidStartInput }
        return try await post(AtlasRoute.arenaRuns, body: input, timeout: 30)
    }
}
