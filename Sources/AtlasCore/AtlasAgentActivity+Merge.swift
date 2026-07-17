import Foundation

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

/// Escolhe o passo que merece o slot de atividade AO VIVO.
public func atlasCurrentAgentActivity(
    from activities: [AtlasAgentActivity]
) -> AtlasAgentActivity? {
    let activeKinds: Set<AtlasAgentActivity.Kind> = [.executing, .reading, .editing]
    return activities.last(where: {
        $0.id.contains(":item:") && activeKinds.contains($0.kind)
    }) ?? activities.last
}
