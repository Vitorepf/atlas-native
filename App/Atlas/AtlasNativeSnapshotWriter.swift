import Foundation
import AtlasCore

/// Escreve o SD-1 no App Group. O writer só agrega dados já vistos pelos models;
/// fonte ausente vira seção ausente, nunca número ou saúde inventados.
@MainActor
final class AtlasNativeSnapshotWriter {
    static let shared = AtlasNativeSnapshotWriter()

    private var latestFleet: AtlasNativeSnapshot.Fleet?
    private var latestWeek: AtlasNativeSnapshot.Week?
    private var latestQueuedCount: Int?
    private var latestRemoteLiveSessions: [LiveSessionSnapshot] = []
    private let store: AtlasNativeSnapshotStore?

    private init() {
        if let file = AtlasNativeSnapshotStore.appGroupFileURL() {
            store = AtlasNativeSnapshotStore(fileURL: file)
        } else {
            store = nil
        }
    }

    func recordAutonomos(_ model: AutonomosModel) {
        latestFleet = Self.fleet(from: model)
        Task { await write() }
    }

    func recordCodeWeek(_ week: AtlasCodeWeek?) {
        latestWeek = week.map {
            AtlasNativeSnapshot.Week(
                window: $0.window,
                commits: $0.commits,
                heals: $0.heals,
                prevented: $0.prevented
            )
        }
        Task { await write() }
    }

    func recordQueuedCount(_ count: Int) {
        latestQueuedCount = max(0, count)
        Task { await write() }
    }

    func recordRemoteLiveSessions(_ sessions: [LiveSessionSnapshot]) {
        latestRemoteLiveSessions = sessions
        Task { await write() }
    }

    func write() async {
        guard let store else { return }
        let snapshot = AtlasNativeSnapshot(
            generatedAt: Date(),
            liveSessions: Self.liveSessions(from: TurnPresence.shared.liveSessions + latestRemoteLiveSessions),
            fleet: latestFleet,
            week: latestWeek,
            queuedCount: latestQueuedCount
        )
        try? await store.save(snapshot)
    }
}
