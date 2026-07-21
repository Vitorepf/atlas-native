import AtlasCore
import Foundation

// Cycle 038 fuse → AtlasCodeWhySheet+A11yLabels.swift

extension AtlasCodeWhySheet {
    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}

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

extension AtlasCodeWhySheet {
    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        parts.append(contentsOf: whySheetHistoryParts())
        return parts.joined(separator: ", ")
    }
}
