import Foundation
import AtlasCore

// Why history spoken — peel de AtlasCodeWhySheet+A11yLabels+Sheet.

extension AtlasCodeWhySheet {
    func whySheetHistoryParts() -> [String] {
        guard model.phase == .loaded, let why = model.why else { return [] }
        if why.commits.isEmpty {
            return ["sem história neste recorte"]
        }
        var history = "\(why.commits.count) commit\(why.commits.count == 1 ? "" : "s")"
        if why.truncated { history += " de \(why.commitsTotal), história truncada" }
        return [history]
    }
}
