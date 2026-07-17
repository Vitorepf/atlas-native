import Foundation
import AtlasCore

/// Why loaded phase id — peel de AtlasCodeWhySheet+A11y.

extension AtlasCodeWhySheet {
    var whyContentLoadedID: String {
        guard let why = model.why else { return "loaded-nil" }
        return why.commits.isEmpty ? "empty" : "timeline-\(why.commits.count)"
    }
}
