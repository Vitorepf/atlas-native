import SwiftUI
import ActivityKit
import AtlasCore

// WAVE-018 — one ContentState phase grammar for Island + Lock.
// Faces exclusive: finished | multiSession | paused | running.
// Badges (ATT/EXT/FAIL/REC/PLN) are overlays from phaseTitle only — not faces.

enum AtlasTurnGlanceFace: String, Equatable {
    case finished
    case multiSession
    case paused
    case running
}

extension AtlasTurnAttributes.ContentState {
    /// Mutual-exclusive face for glance chrome (DoD WAVE-018).
    var glanceFace: AtlasTurnGlanceFace {
        if finished { return .finished }
        if activeSessions > 1 { return .multiSession }
        if paused == true { return .paused }
        return .running
    }

    var isFailed: Bool {
        phaseTitle.localizedCaseInsensitiveContains("falhou")
    }

    var isAttention: Bool {
        phaseTitle.localizedCaseInsensitiveContains("atenção")
            || phaseTitle.localizedCaseInsensitiveContains("aguard")
            || phaseTitle.localizedCaseInsensitiveContains("decisão")
    }

    /// Timer only when not finished (no false 0:00 after terminal).
    var showsGlanceTimer: Bool {
        !finished
    }

    /// Silence gold chrome when finished healthy (no fail badge).
    var silenceHealthyFinished: Bool {
        finished && !isFailed
    }

    var atlasColorTerminal: Color? {
        if isFailed { return Ink.alert }
        if finished { return Ink.healed }
        return nil
    }

    var atlasColor: Color {
        if let terminal = atlasColorTerminal { return terminal }
        if paused == true || isAttention { return Ink.alert }
        return Ink.gold
    }

    var atlasSymbolTerminal: String? {
        if isFailed { return "✕" }
        if finished { return "✓" }
        return nil
    }

    var atlasSymbol: String {
        if let terminal = atlasSymbolTerminal { return terminal }
        if isAttention { return "⚠" }
        if paused == true { return "‖" }
        return "✦"
    }

    /// SD-2: badge from canonical phaseTitle only.
    var phaseBadge: String? {
        phaseBadgeFailAtt ?? phaseBadgeExtRecPln
    }

    var phaseBadgeFailAtt: String? {
        let p = phaseTitle.lowercased()
        if p.contains("falhou") { return "FAIL" }
        if p.contains("atenção") || p.contains("decisão") { return "ATT" }
        return nil
    }

    var phaseBadgeExtRecPln: String? {
        let p = phaseTitle.lowercased()
        if p.contains("sistema externo") || (p.contains("aguard") && p.contains("extern")) {
            return "EXT"
        }
        if p.contains("reconect") { return "REC" }
        if p.contains("replanej") { return "PLN" }
        return nil
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
