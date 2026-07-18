import SwiftUI
import AtlasCore

// Linha de ritmo — autossuficiente: lê as janelas aprendidas do AtlasDayRhythm
// e abre a folha "O ritmo do seu dia" ao toque. O aprendizado não some quando
// completa: a linha amadurece e passa a dizer o que foi aprendido.
// Sheet → AutonomosRhythmSheet.swift · Copy → AutonomosRhythmSheet+Copy.swift

struct AutonomosRhythmLearningLine: View {
    @State private var windows: AtlasDayRhythm.Windows?
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Group {
            if windows == nil {
                // Reserva a altura da linha: view VAZIA em LazyVStack nunca
                // "aparece" e o .task nunca dispara (ovo-e-galinha que sumiu
                // com a linha do app). O texto pousa sem pulo de layout.
                Text(" ").font(AtlasFont.mono(10)).accessibilityHidden(true)
            }
            if let windows {
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
                .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
                .accessibilityIdentifier(A11yID.autonomosRhythmLine)
                .sheet(isPresented: $rhythmSheetShown) {
                    AutonomosRhythmSheet(windows: windows)
                }
            }
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}
