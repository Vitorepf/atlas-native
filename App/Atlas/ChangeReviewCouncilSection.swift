import AtlasCore
import SwiftUI

// Cycle 040 fuse → ChangeReviewCouncilSection.swift

// MARK: - Governance / Conselho (C18 · C19 · C21)

/// C18 · C19 · C21 — as provas que o servidor emite. Cada bloco só existe
/// se a fonte existir: sem diff medido, sem replanejamento e sem conselho,
/// esta seção inteira desaparece (estado por exceção).
struct ChangeReviewGovernanceSection: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        governanceTraceGate
    }
}
