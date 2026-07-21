import SwiftUI

// Timeline filter labels — peel de LiveTimeline+FilterEnum.

extension TimelineReadFilter {
    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}
