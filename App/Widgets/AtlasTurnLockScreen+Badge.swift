import SwiftUI
import ActivityKit
import AtlasCore

/// Badges ATT/EXT/FAIL — peel de AtlasTurnLockScreen+State.

extension AtlasTurnAttributes.ContentState {
    /// SD-2: badge curto derivado só de `phaseTitle` canônico do Core
    /// (`AtlasExecutionPresence`) — sem inventar kind paralelo no widget.
    var phaseBadge: String? {
        let p = phaseTitle.lowercased()
        if p.contains("falhou") { return "FAIL" }
        if p.contains("atenção") || p.contains("decisão") { return "ATT" }
        if p.contains("sistema externo") || (p.contains("aguard") && p.contains("extern")) { return "EXT" }
        if p.contains("reconect") { return "REC" }
        if p.contains("replanej") { return "PLN" }
        return nil
    }
}
