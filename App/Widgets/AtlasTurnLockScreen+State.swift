import SwiftUI
import ActivityKit
import AtlasCore

/// Derivações visuais do lock screen — peel de `AtlasTurnLockScreen`.
/// Badge → AtlasTurnLockScreen+Badge.swift
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

    var progressLabel: String? {
        guard let current = progressCurrent, let total = progressTotal, total > 0 else { return nil }
        return "\(min(max(current, 0), total))/\(total)"
    }

    var queueLabel: String? {
        guard let count = queuedCount, count > 0 else { return nil }
        return "fila \(count)"
    }
}
