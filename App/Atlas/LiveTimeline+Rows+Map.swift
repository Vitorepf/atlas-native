import SwiftUI
import AtlasCore

// Map activities → NarrativeRow — peel de LiveTimeline+Rows.

func narrativeRowMap(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
}
