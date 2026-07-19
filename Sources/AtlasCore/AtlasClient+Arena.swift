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

    func getArenaReport() async throws -> AtlasArenaReport {
        try await get(AtlasRoute.arenaReport)
    }

    func getArenaCapabilities(engine: String) async throws -> AtlasArenaCapabilities {
        try await get(AtlasRoute.arenaCapabilities(engine: engine))
    }

    func getArenaLiveRuns() async throws -> AtlasArenaLiveRuns {
        try await get(AtlasRoute.arenaLiveRuns)
    }

    func getArenaEngines() async throws -> AtlasArenaEngines {
        try await get(AtlasRoute.arenaEngines)
    }

    func startArenaRuns(input: AtlasArenaStartInput) async throws -> AtlasArenaStartReceipt {
        guard input.isLocallyValidForSubmission else { throw AtlasArenaClientError.invalidStartInput }
        return try await post(AtlasRoute.arenaRuns, body: input, timeout: 30)
    }

    func stopArenaMeasurement(
        measurementId: String,
        input: AtlasArenaStopInput
    ) async throws -> AtlasArenaStopReceipt {
        guard input.isLocallyValidForSubmission else { throw AtlasArenaClientError.invalidStartInput }
        return try await post(AtlasRoute.arenaStop(measurementId: measurementId), body: input, timeout: 30)
    }
}
