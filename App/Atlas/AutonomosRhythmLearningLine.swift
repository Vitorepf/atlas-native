import SwiftUI
import AtlasCore

// Linha de ritmo — autossuficiente: lê as janelas aprendidas do AtlasDayRhythm
// e abre a folha "O ritmo do seu dia" ao toque. O aprendizado não some quando
// completa: a linha amadurece e passa a dizer o que foi aprendido.
// Sheet → AutonomosRhythmSheet.swift · Copy → AutonomosRhythmSheet+Copy.swift

struct AutonomosRhythmLearningLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Placeholder até o actor devolver as janelas reais — a linha existe
    /// imediatamente (UITest + layout estáveis).
    @State private var windows = AtlasDayRhythm.Windows(dayEnd: nil, dayStart: nil, sampleDays: 0)
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            rhythmSheetShown = true
        } label: {
            HStack(spacing: 5) {
                Text(AutonomosRhythmCopy.line(windows, paused: nightly.isProposalMuted))
                    .font(AtlasFont.mono(10))
                    .lineLimit(2)
                Image(systemName: "chevron.right")
                    .atlasSans(7, .semibold)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows, paused: nightly.isProposalMuted))
        .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosRhythmLine)
        .sheet(isPresented: $rhythmSheetShown) {
            AutonomosRhythmSheet(windows: windows)
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}
