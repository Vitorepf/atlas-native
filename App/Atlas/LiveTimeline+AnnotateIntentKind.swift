import SwiftUI
import AtlasCore

// Intent kind predicate — peel de LiveTimeline+Annotate.

func isNarrativeIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}
