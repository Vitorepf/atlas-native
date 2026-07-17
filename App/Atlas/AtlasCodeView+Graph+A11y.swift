import SwiftUI
import AtlasCore

/// Spoken labels do grafo — peel de AtlasCodeView+Graph (CICLO C residual honesty).
/// Filter → AtlasCodeView+Graph+A11yFilter.swift

enum AtlasCodeGraphA11y {
    static func spokenStatus(scanState: AtlasCodeScanState, headline: String) -> String {
        switch scanState {
        case .clean, .unknown:
            return headline
        case .violating:
            return "atenção, \(headline)"
        }
    }
}
