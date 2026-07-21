import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Autonomos small types/chrome fused

// MARK: - AutonomosUnit

struct AutonomosUnit: Identifiable, Equatable, Hashable {
    let id: String
    var name: String
    var charter: String
    var createdAt: Date
    var paused: Bool

    var ageLabel: String {
        let seconds = max(0, Int(Date().timeIntervalSince(createdAt)))
        if seconds < 60 { return "agora" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86_400 { return "\(seconds / 3600)h" }
        let days = seconds / 86_400
        return days == 1 ? "1 dia" : "\(days) dias"
    }
}
// MARK: - AutonomosDestination

enum AutonomosDestination: Hashable, Identifiable {
    case hub
    case evolution
    case decisions
    case decisionInbox(String)
    case decisionOrder(String)
    case moment(String)
    case incident

    var id: String {
        switch self {
        case .hub: "hub"
        case .evolution: "evolution"
        case .decisions: "decisions"
        case .decisionInbox(let h): "inbox-\(h)"
        case .decisionOrder(let id): "order-\(id)"
        case .moment(let id): "moment-\(id)"
        case .incident: "incident"
        }
    }

    var navTitle: String {
        switch self {
        case .hub: "Autônomo"
        case .evolution: "Evolução"
        case .decisions: "Decisões"
        case .decisionInbox, .decisionOrder: "Decisão"
        case .moment: "Momento"
        case .incident: "Precisa de você"
        }
    }

    /// Voltar hierárquico: profundidade → hub → lista.
    var backTarget: AutonomosDestination? {
        switch self {
        case .hub: nil
        default: .hub
        }
    }
}
// MARK: - AutonomosMapNavLine

struct AutonomosMapNavLine: View {
    let title: String
    let meta: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(AtlasFont.serif(16, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(meta)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                Text("›")
                    .font(AtlasFont.serif(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
    }
}
// MARK: - AutonomosRhythmLearningLine

struct AutonomosRhythmLearningLine: View {
    /// Placeholder até o actor devolver as janelas reais — a linha existe
    /// imediatamente (UITest + layout estáveis).
    @State private var windows = AtlasDayRhythm.Windows(dayEnd: nil, dayStart: nil, sampleDays: 0)
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Button {
            rhythmSheetShown = true
        } label: {
            HStack(spacing: 5) {
                Text(AutonomosRhythmCopy.line(windows, paused: nightly.isProposalMuted))
                    .font(AtlasFont.mono(10))
                Image(systemName: "chevron.right")
                    .atlasSans(7, .semibold)
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows, paused: nightly.isProposalMuted))
        .accessibilityValue(
            AutonomosRhythmJudgment.face(
                windows: windows,
                paused: nightly.isProposalMuted
            ).productWord
        )
        .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
        .accessibilityIdentifier(A11yID.autonomosRhythmLine)
        .sheet(isPresented: $rhythmSheetShown) {
            AutonomosRhythmSheet(windows: windows)
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}
