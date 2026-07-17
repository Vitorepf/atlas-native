import Foundation

/// Projeta o ledger persistido numa timeline editorial: ordenada e sem repetir
/// cada chunk de transporte como se fosse uma nova ação do agente.
public func atlasAgentTimeline(from events: [AtlasAiStreamEvent]) -> [AtlasAgentActivity] {
    var projection = AtlasAgentTimelineProjection()
    return projection.merge(events: events, limit: .max)
}

/// Cache incremental da timeline do ledger.
public struct AtlasAgentTimelineProjection: Sendable {
    public private(set) var timeline: [AtlasAgentActivity] = []
    public private(set) var lastProjected: Int?

    private var indexById: [String: Int] = [:]

    public init() {}

    @discardableResult
    public mutating func merge(
        events: [AtlasAiStreamEvent],
        limit: Int = 60,
        projectionCounter: (() -> Void)? = nil
    ) -> [AtlasAgentActivity] {
        guard limit > 0 else {
            timeline.removeAll()
            indexById.removeAll()
            return timeline
        }

        let floor = lastProjected ?? Int.min
        let newEvents = events
            .filter { $0.sequence > floor }
            .sorted { $0.sequence < $1.sequence }
        guard !newEvents.isEmpty else { return timeline }

        var projected: [AtlasAgentActivity] = []
        projected.reserveCapacity(newEvents.count)
        var maxSequence = floor
        for event in newEvents {
            projectionCounter?()
            maxSequence = max(maxSequence, event.sequence)
            if let activity = atlasAgentActivity(from: event) {
                projected.append(activity)
            }
        }
        lastProjected = maxSequence
        merge(projected, limit: limit)
        return timeline
    }

    public mutating func merge(
        activities incoming: [AtlasAgentActivity],
        limit: Int = 60
    ) {
        merge(incoming, limit: limit)
    }

    private mutating func merge(
        _ incoming: [AtlasAgentActivity],
        limit: Int
    ) {
        for activity in incoming {
            if let index = indexById[activity.id] {
                timeline[index] = activity
                continue
            }
            if let last = timeline.last,
               last.kind == activity.kind,
               last.title == activity.title,
               last.detail == activity.detail {
                continue
            }
            indexById[activity.id] = timeline.count
            timeline.append(activity)
        }
        if timeline.count > limit {
            timeline.removeFirst(timeline.count - limit)
            rebuildIndex()
        }
    }

    private mutating func rebuildIndex() {
        indexById.removeAll(keepingCapacity: true)
        for (offset, activity) in timeline.enumerated() {
            indexById[activity.id] = offset
        }
    }
}
