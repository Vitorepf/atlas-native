import Foundation

/// Projeta o ledger persistido numa timeline editorial: ordenada e sem repetir
/// cada chunk de transporte como se fosse uma nova ação do agente.
public func atlasAgentTimeline(from events: [AtlasAiStreamEvent]) -> [AtlasAgentActivity] {
    var projection = AtlasAgentTimelineProjection()
    return projection.merge(events: events, limit: .max)
}

/// Cache incremental da timeline do ledger. Snapshots de poll chegam com o
/// ledger inteiro, mas só eventos acima do último `sequence` precisam virar
/// `AtlasAgentActivity` novamente.
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

/// Um tool do Codex muda de fase mantendo `item_id`; substituir preserva uma
/// linha viva e impede IDs repetidos no ForEach. Eventos sem identidade de item
/// continuam append-only, com colapso apenas de chunks editoriais equivalentes.
public func atlasMergeAgentActivities(
    existing: [AtlasAgentActivity],
    incoming: [AtlasAgentActivity],
    limit: Int = 60
) -> [AtlasAgentActivity] {
    guard limit > 0 else { return [] }
    var result = existing
    var indexById: [String: Int] = [:]
    indexById.reserveCapacity(result.count + incoming.count)
    for (offset, activity) in result.enumerated() {
        indexById[activity.id] = offset
    }
    for activity in incoming {
        if let index = indexById[activity.id] {
            result[index] = activity
            continue
        }
        if let last = result.last,
           last.kind == activity.kind,
           last.title == activity.title,
           last.detail == activity.detail {
            continue
        }
        indexById[activity.id] = result.count
        result.append(activity)
    }
    if result.count > limit {
        result.removeFirst(result.count - limit)
    }
    return result
}

/// Escolhe o passo que merece o slot de atividade AO VIVO. Um provider pode
/// continuar emitindo reasoning/progress enquanto uma ferramenta ainda está
/// aberta; `activities.last` faria esse ruído substituir a ação real. Como o
/// merge troca started→completed pelo mesmo item, basta priorizar o item de
/// tool mais recente que ainda tem um kind ativo.
public func atlasCurrentAgentActivity(
    from activities: [AtlasAgentActivity]
) -> AtlasAgentActivity? {
    let activeKinds: Set<AtlasAgentActivity.Kind> = [.executing, .reading, .editing]
    return activities.last(where: {
        $0.id.contains(":item:") && activeKinds.contains($0.kind)
    }) ?? activities.last
}
