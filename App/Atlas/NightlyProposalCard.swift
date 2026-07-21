import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    /// Hora aprendida do fim do dia — o masthead diz o ritmo real, não "21h" fixo.
    @State var learnedDayEnd: String?

    var body: some View {
        cardA11y
            .task {
                let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
                learnedDayEnd = AutonomosRhythmCopy.hour(windows.dayEnd)
            }
    }
}

