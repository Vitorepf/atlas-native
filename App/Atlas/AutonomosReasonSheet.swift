import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Form → AutonomosReasonSheet+Form.swift
/// Submit → AutonomosReasonSheet+Submit.swift
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

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
