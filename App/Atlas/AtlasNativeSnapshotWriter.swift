import AtlasCore
import Foundation
import WidgetKit

// Cycle 044 fuse → AtlasNativeSnapshotWriter.swift

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
        // Widgets só refrescam se o App Group estiver provisionado; reload é barato.
        WidgetCenter.shared.reloadAllTimelines()
    }
}

extension AtlasNativeSnapshotWriter {
    static func fleet(from model: AutonomosModel) -> AtlasNativeSnapshot.Fleet? {
        guard model.taskHealth != nil || model.delivered != nil else { return nil }
        let health = model.taskHealth
        let delivery = model.delivered?.delivered.max {
            AtlasTime.ms($0.recordedAt) < AtlasTime.ms($1.recordedAt)
        }
        let incident: AtlasNativeSnapshot.Fleet.Incident?
        if health?.incidents.present == true {
            incident = AtlasNativeSnapshot.Fleet.Incident(
                present: true,
                flags: health?.incidents.flags ?? [],
                recommendedAction: health?.operating.recommendedAction
            )
        } else {
            incident = nil
        }
        return AtlasNativeSnapshot.Fleet(
            scannedAt: health?.observedAt,
            incident: incident,
            lastDelivery: delivery.map {
                AtlasNativeSnapshot.Fleet.LastDelivery(
                    title: "ciclo \($0.cycleIndex) · \($0.outcome)",
                    mergeHash: $0.mergeHash,
                    at: $0.recordedAt
                )
            }
        )
    }

    static func iso(_ date: Date) -> String {
        date.formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false).timeZone(separator: .omitted))
    }
}

extension AtlasNativeSnapshotWriter {
    static func liveSessions(from sessions: [LiveSessionSnapshot]) -> [AtlasNativeSnapshot.LiveSession]? {
        let projected = sessions.map { session in
            AtlasNativeSnapshot.LiveSession(
                title: session.title,
                phaseTitle: session.phaseTitle,
                timing: timing(from: session.timing),
                elapsedActiveMs: session.elapsedActiveMs,
                runningSince: session.runningSince.map(iso)
            )
        }
        return projected.isEmpty ? [] : projected
    }

    static func timing(from timing: AtlasExecutionPresence.Timing) -> AtlasNativeSnapshot.LiveSession.Timing {
        switch timing {
        case .running: return .running
        case .paused: return .paused
        case .finished: return .finished
        }
    }
}
