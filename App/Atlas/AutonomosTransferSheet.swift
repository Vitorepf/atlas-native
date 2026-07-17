import SwiftUI
import AtlasCore

/// Folha de transferência — só placement verificado do lock; alvo nunca inventado.
/// Form → AutonomosTransferSheet+Form.swift · Placement → +Placement.swift · Toolbar → +Toolbar.swift
struct AutonomosTransferSheet: View {
    let areaName: String
    let focus: String
    let placement: AtlasAutonomosRuntimePlacement?
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            transferForm
            .navigationTitle("Transferir missão")
            .toolbar { transferToolbar }
            .accessibilityIdentifier(A11yID.autonomosTransferSheet)
        }
        .accessibilityLabel(
            AutonomosTransferSheetA11y.spokenSheet(areaName: areaName, hasPlacement: hasPlacement)
        )
        .accessibilityHint(AutonomosTransferSheetA11y.sheetHint)
    }

    var hasPlacement: Bool { placement?.hasVerifiedPlacement == true }

    var canConfirm: Bool {
        hasPlacement
            && !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
