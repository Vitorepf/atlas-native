import Foundation
import AtlasCore

// Why sheet spoken — peel de AtlasCodeWhySheet+A11y.

extension AtlasCodeWhySheet {
    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        if model.phase == .loaded, let why = model.why {
            if why.commits.isEmpty {
                parts.append("sem história neste recorte")
            } else {
                var history = "\(why.commits.count) commit\(why.commits.count == 1 ? "" : "s")"
                if why.truncated { history += " de \(why.commitsTotal), história truncada" }
                parts.append(history)
            }
        }
        return parts.joined(separator: ", ")
    }

    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}
