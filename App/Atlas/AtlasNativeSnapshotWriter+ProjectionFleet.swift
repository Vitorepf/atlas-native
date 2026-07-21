import Foundation
import AtlasCore

/// Fleet projection — peel de AtlasNativeSnapshotWriter+Projection.

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
