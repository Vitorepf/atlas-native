import SwiftUI
import AtlasCore

/// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
/// Body → AutonomosFleetTransfer+Body.swift
/// Header → AutonomosFleetTransfer+Header.swift
struct AutonomosTransferStatus: View {
    let transfer: AtlasAutonomosTransferResponse
    let onRefresh: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            transferHeader
            transferBody
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosTransferStatus)
    }
}
