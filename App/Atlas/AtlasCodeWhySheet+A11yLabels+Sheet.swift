import Foundation
import AtlasCore

// Sheet spoken — peel de AtlasCodeWhySheet+A11yLabels.
// History → AtlasCodeWhySheet+A11yLabels+Sheet+History.swift

extension AtlasCodeWhySheet {
    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        parts.append(contentsOf: whySheetHistoryParts())
        return parts.joined(separator: ", ")
    }
}
