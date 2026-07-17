import SwiftUI
import ActivityKit
import AtlasCore

/// Derivações visuais do lock screen — peel de `AtlasTurnLockScreen`.
/// Badge → AtlasTurnLockScreen+Badge.swift
/// Labels → AtlasTurnLockScreen+StateLabels.swift
/// Symbol → AtlasTurnLockScreen+Symbol.swift
/// Terminal → AtlasTurnLockScreen+State+Terminal.swift
extension AtlasTurnAttributes.ContentState {
    var atlasColor: Color {
        if let terminal = atlasColorTerminal { return terminal }
        if paused == true
            || phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard") {
            return Ink.alert
        }
        return Ink.gold
    }
}
