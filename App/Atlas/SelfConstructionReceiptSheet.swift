import SwiftUI
import AtlasCore

// Stack → SelfConstructionReceiptSheet+Stack.swift
// Predicates → SelfConstructionReceiptSheet+Predicates.swift
// Shell → SelfConstructionReceiptSheet+Shell.swift
struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        receiptShell
    }
}
