import Foundation
import AtlasCore

// Effort light subtitles — peel de ComposerSheets A11yEffortSubtitle.

extension ComposerSheetA11y {
    static func effortSubtitleLight(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        default: return nil
        }
    }
}
