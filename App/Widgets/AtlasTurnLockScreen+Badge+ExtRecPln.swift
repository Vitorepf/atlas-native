import SwiftUI
import ActivityKit
import AtlasCore

/// EXT/REC/PLN badges — peel de AtlasTurnLockScreen+Badge.

extension AtlasTurnAttributes.ContentState {
    var phaseBadgeExtRecPln: String? {
        let p = phaseTitle.lowercased()
        if p.contains("sistema externo") || (p.contains("aguard") && p.contains("extern")) { return "EXT" }
        if p.contains("reconect") { return "REC" }
        if p.contains("replanej") { return "PLN" }
        return nil
    }
}
