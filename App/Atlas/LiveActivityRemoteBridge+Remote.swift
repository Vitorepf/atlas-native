import Foundation
import AtlasCore
#if canImport(ActivityKit)
import ActivityKit

/// Bootstrap e activities remotas — peel de LiveActivityRemoteBridge.
/// Start token → LiveActivityRemoteBridge+RemoteBootstrap.swift
/// Activity updates → LiveActivityRemoteBridge+RemoteObserve.swift

extension LiveActivityRemoteBridge {
    func bootstrap(client: AtlasClient, installationId: String) {
        bootstrapStartToken(client: client, installationId: installationId)
        bootstrapRemoteActivities(client: client, installationId: installationId)
    }
}
#endif
