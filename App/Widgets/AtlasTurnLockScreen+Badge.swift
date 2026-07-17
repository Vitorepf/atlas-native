import SwiftUI
import ActivityKit
import AtlasCore

/// Badges ATT/EXT/FAIL — peel de AtlasTurnLockScreen+State.
/// FailAtt → AtlasTurnLockScreen+Badge+FailAtt.swift
/// ExtRecPln → AtlasTurnLockScreen+Badge+ExtRecPln.swift

extension AtlasTurnAttributes.ContentState {
    /// SD-2: badge curto derivado só de `phaseTitle` canônico do Core
    /// (`AtlasExecutionPresence`) — sem inventar kind paralelo no widget.
    var phaseBadge: String? {
        phaseBadgeFailAtt ?? phaseBadgeExtRecPln
    }
}
