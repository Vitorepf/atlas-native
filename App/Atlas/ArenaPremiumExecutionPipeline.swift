import SwiftUI
import AtlasCore

/// Fase macro da medição — presentation-only, derivada dos runs vivos.
enum ArenaPremiumPipelineStep: Int, CaseIterable, Identifiable {
    case prepare
    case bare
    case withAtlas
    case consolidate

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .prepare: "Preparar"
        case .bare: "Sem Atlas"
        case .withAtlas: "Com Atlas"
        case .consolidate: "Consolidar"
        }
    }
}

enum ArenaPremiumPipelineMark {
    case pending
    case live
    case done
}

struct ArenaPremiumPipelineProjection: Equatable {
    let marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark]

    static func project(
        runs: [AtlasArenaLiveRun],
        expectsBare: Bool,
        expectsAtlas: Bool,
        hasReport: Bool
    ) -> ArenaPremiumPipelineProjection {
        var marks: [ArenaPremiumPipelineStep: ArenaPremiumPipelineMark] = [:]
        let bare = runs.filter { $0.arm == .baseline }
        let atlas = runs.filter { $0.arm == .withAtlas }
        let anyLive = runs.contains { $0.status == .running || $0.status == .stopping }
        let allQueued = !runs.isEmpty && runs.allSatisfy { $0.status == .queued }
        let allTerminal = !runs.isEmpty && runs.allSatisfy(Self.isTerminal)

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
        } else if anyLive || allQueued {
            marks[.consolidate] = .pending
        } else {
            marks[.consolidate] = .pending
        }

        return ArenaPremiumPipelineProjection(marks: marks)
    }

    private static func armMark(
        _ armRuns: [AtlasArenaLiveRun],
        expected: Bool,
        prepareDone: Bool
    ) -> ArenaPremiumPipelineMark {
        guard expected else { return prepareDone ? .done : .pending }
        if armRuns.contains(where: { $0.status == .running || $0.status == .stopping }) {
            return .live
        }
        if !armRuns.isEmpty, armRuns.allSatisfy(isTerminal) {
            return .done
        }
        return .pending
    }

    private static func isTerminal(_ run: AtlasArenaLiveRun) -> Bool {
        switch run.status {
        case .completed, .failed, .stopped: true
        default: false
        }
    }
}

struct ArenaPremiumExecutionPipeline: View {
    let projection: ArenaPremiumPipelineProjection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pipeline")
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            HStack(alignment: .top, spacing: 0) {
                ForEach(ArenaPremiumPipelineStep.allCases) { step in
                    stepColumn(step)
                    if step != .consolidate {
                        pipelineRail(after: step)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(A11yID.arenaPremiumExecutionPipeline)
    }

    private func stepColumn(_ step: ArenaPremiumPipelineStep) -> some View {
        let mark = projection.marks[step] ?? .pending
        return VStack(spacing: 8) {
            Text(glyph(step, mark))
                .font(AtlasFont.serif(14))
                .foregroundStyle(color(mark))
                .frame(height: 20)
            Text(step.title)
                .font(AtlasFont.mono(9, .medium))
                .foregroundStyle(mark == .pending ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func pipelineRail(after step: ArenaPremiumPipelineStep) -> some View {
        let done = (projection.marks[step] ?? .pending) == .done
        return Rectangle()
            .fill(done ? AtlasTheme.separator : AtlasTheme.separator.opacity(0.35))
            .frame(width: 18, height: 1)
            .padding(.top, 10)
            .accessibilityHidden(true)
    }

    /// Corrida ao vivo usa ▸; ✦ só na fase cujo nome é Atlas.
    private func glyph(_ step: ArenaPremiumPipelineStep, _ mark: ArenaPremiumPipelineMark) -> String {
        switch mark {
        case .done: "✓"
        case .pending: "○"
        case .live:
            step == .withAtlas ? "✦" : "▸"
        }
    }

    private func color(_ mark: ArenaPremiumPipelineMark) -> Color {
        switch mark {
        case .live: AtlasTheme.accent
        case .done: AtlasTheme.textPrimary
        case .pending: AtlasTheme.textTertiary
        }
    }

    private var spoken: String {
        ArenaPremiumPipelineStep.allCases.map { step in
            let mark = projection.marks[step] ?? .pending
            let state: String = switch mark {
            case .done: "feito"
            case .live: "ao vivo"
            case .pending: "pendente"
            }
            return "\(step.title) \(state)"
        }.joined(separator: ", ")
    }
}
