import Foundation
import AtlasCore

// Header spoken — peel de AtlasCodeWhySheet+A11yLabels.

extension AtlasCodeWhySheet {
    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}
