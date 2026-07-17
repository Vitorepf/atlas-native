import SwiftUI
import ActivityKit
import AtlasCore

/// FAIL/ATT badges — peel de AtlasTurnLockScreen+Badge.

extension AtlasTurnAttributes.ContentState {
    var phaseBadgeFailAtt: String? {
        let p = phaseTitle.lowercased()
        if p.contains("falhou") { return "FAIL" }
        if p.contains("atenção") || p.contains("decisão") { return "ATT" }
        return nil
    }
}
