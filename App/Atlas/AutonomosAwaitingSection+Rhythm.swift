import SwiftUI
import AtlasCore

// Linha de ritmo — autossuficiente: lê as janelas aprendidas do AtlasDayRhythm
// e abre a folha "O ritmo do seu dia" ao toque. O aprendizado não some quando
// completa: a linha amadurece e passa a dizer o que foi aprendido.
// Sheet → AutonomosRhythmSheet.swift · Copy → AutonomosRhythmSheet+Copy.swift

struct AutonomosRhythmLearningLine: View {
    @State private var windows: AtlasDayRhythm.Windows?
    @State private var rhythmSheetShown = false

    var body: some View {
        Group {
            if let windows {
                Button {
                    rhythmSheetShown = true
                } label: {
                    HStack(spacing: 5) {
                        Text(AutonomosRhythmCopy.line(windows))
                            .font(AtlasFont.mono(10))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 7, weight: .semibold))
                    }
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows))
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
