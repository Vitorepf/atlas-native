import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Start-token bootstrap — peel de LiveActivityRemoteBridge+Remote.

extension LiveActivityRemoteBridge {
    func bootstrapStartToken(client: AtlasClient, installationId: String) {
        guard #available(iOS 17.2, *), startTokenTask == nil else { return }
        startTokenTask = Task { @MainActor [weak self] in
            guard self != nil else { return }
            for await token in Activity<AtlasTurnAttributes>.pushToStartTokenUpdates {
                guard !Task.isCancelled else { break }
                _ = try? await client.registerLiveActivityStartToken(.init(
                    installationId: installationId,
                    pushToken: token.atlasHex,
                    environment: Self.environment
                ))
            }
        }
    }
}
#endif
