import Foundation
import AtlasCore

// Effort subtitles — peel de ConversationChrome+ComposerSheets+A11yEffort.
// Light → ConversationChrome+ComposerSheets+A11yEffortSubtitle+Light.swift

extension ComposerSheetA11y {
    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        if let light = effortSubtitleLight(effort) { return light }
        switch effort {
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        default: return "Atlas Decide escolhe; nada vai no payload"
        }
    }
}
