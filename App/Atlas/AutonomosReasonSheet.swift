import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Form → AutonomosReasonSheet+Form.swift
/// Submit → AutonomosReasonSheet+Submit.swift
/// Init → AutonomosReasonSheet+Init.swift
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            reasonForm
            .navigationTitle("Confirmar ação")
            .toolbar { reasonToolbar }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
        }
    }
}
