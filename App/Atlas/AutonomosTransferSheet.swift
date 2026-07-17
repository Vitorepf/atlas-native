import SwiftUI
import AtlasCore

/// Folha de transferência — só placement verificado do lock; alvo nunca inventado.
/// Form → AutonomosTransferSheet+Form.swift · Placement → +Placement.swift · Toolbar → +Toolbar.swift
/// Predicates → AutonomosTransferSheet+Predicates.swift
/// A11y → AutonomosTransferSheet+A11yChrome.swift
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
        transferA11yChrome(transferNavigationStack)
    }
}
