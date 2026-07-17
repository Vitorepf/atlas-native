import SwiftUI
import ActivityKit
import AtlasCore

/// Derivações visuais do lock screen — peel de `AtlasTurnLockScreen`.
/// Badge → AtlasTurnLockScreen+Badge.swift
/// Labels → AtlasTurnLockScreen+StateLabels.swift
extension AtlasTurnAttributes.ContentState {
    var atlasColor: Color {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return Ink.alert }
        if finished { return Ink.healed }
        if paused == true
            || phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard") {
            return Ink.alert
        }
        return Ink.gold
    }

    var atlasSymbol: String {
        if phaseTitle.localizedCaseInsensitiveContains("falhou") { return "✕" }
        if finished { return "✓" }
        if phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard") {
            return "⚠"
        }
        if paused == true { return "‖" }
        return "✦"
    }
}
