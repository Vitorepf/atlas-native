import Foundation
import AtlasCore
import SwiftUI

// MARK: - Judgment

/// Pure Arena execution pipeline projection (WAVE-109).
/// Never invents arm marks beyond published live runs + report flag.
enum ArenaPipelineJudgment {

    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        var marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark] = [:]
        let bare = runs.filter { $0.arm == .baseline }
        let atlas = runs.filter { $0.arm == .withAtlas }
        let allQueued = !runs.isEmpty && runs.allSatisfy {
            if case .queued = $0.status { return true }
            return false
        }
        let allTerminal = !runs.isEmpty && runs.allSatisfy(isTerminal)

        if runs.isEmpty {
            marks[.prepare] = .pending
        } else if allQueued {
            marks[.prepare] = .live
        } else {
            marks[.prepare] = .done
        }

        marks[.bare] = armMark(
            bare,
            expected: expectsBare || !bare.isEmpty,
            prepareDone: marks[.prepare] == .done
        )
        marks[.withAtlas] = armMark(
            atlas,
            expected: expectsAtlas || !atlas.isEmpty,
            prepareDone: marks[.prepare] == .done
        )

        if allTerminal {
            marks[.consolidate] = hasReport ? .done : .live
        } else {
            marks[.consolidate] = .pending
        }

        return ArenaPremiumPipelineProjection(marks: marks)
    }

    static func armMark(
        _ armRuns: [AtlasArenaLiveRun],
        expected: Bool,
        prepareDone: Bool
    ) -> ArenaPremiumPipelineMark {
        guard expected else { return prepareDone ? .done : .pending }
        if armRuns.contains(where: {
            if case .running = $0.status { return true }
            if case .stopping = $0.status { return true }
            return false
        }) {
            return .live
        }
        if !armRuns.isEmpty, armRuns.allSatisfy(isTerminal) {
            return .done
        }
        return .pending
    }

    static func isTerminal(_ run: AtlasArenaLiveRun) -> Bool {
        switch run.status {
        case .completed, .failed, .stopped: return true
        default: return false
        }
    }

    /// Corrida ao vivo usa ▸; ✦ só na fase cujo nome é Atlas.
    static func glyph(step: ArenaPremiumPipelineStep, mark: ArenaPremiumPipelineMark) -> String {
        switch mark {
        case .done: return "✓"
        case .pending: return "○"
        case .live:
            return step == .withAtlas ? "✦" : "▸"
        }
    }

    static func color(for mark: ArenaPremiumPipelineMark) -> Color {
        switch mark {
        case .live: return AtlasTheme.accent
        case .done: return AtlasTheme.textPrimary
        case .pending: return AtlasTheme.textTertiary
        }
    }

    static func spoken(_ projection: ArenaPremiumPipelineProjection) -> String {
        ArenaPremiumPipelineStep.allCases.map { step in
            let mark = projection.marks[step] ?? .pending
            let state: String
            switch mark {
            case .done: state = "feito"
            case .live: state = "ao vivo"
            case .pending: state = "pendente"
            }
            return "\(step.title) \(state)"
        }.joined(separator: ", ")
    }

    static func packFacts(
        _ projection: ArenaPremiumPipelineProjection
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        for step in ArenaPremiumPipelineStep.allCases {
            let mark = projection.marks[step] ?? .pending
            let word: String
            switch mark {
            case .done: word = "done"
            case .live: word = "live"
            case .pending: word = "pending"
            }
            facts.append("pipeline_\(step.title): \(word)")
        }
        if projection.marks.values.allSatisfy({ $0 == .pending }) {
            absences.append("pipeline sem marcos vivos neste recorte")
        }
        return (facts, absences)
    }
}
