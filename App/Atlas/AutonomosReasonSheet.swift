import SwiftUI

/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Form → AutonomosReasonSheet+Form.swift
/// Submit → AutonomosReasonSheet+Submit.swift
/// Init → AutonomosReasonSheet+Init.swift
/// Navigation → AutonomosReasonSheet+Navigation.swift
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
        reasonNavigation
    }

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

}
