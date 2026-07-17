import Foundation
import AtlasCore

// Effort subtitles — peel de ConversationChrome+ComposerSheets+A11yEffort.

extension ComposerSheetA11y {
    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        }
    }
}
