import SwiftUI
import AtlasCore

// Linhas de recibo — peel de AutonomosLoadedSection+Receipts (CICLO D: um só phase ID).
// Transition → AutonomosLoadedSection+ReceiptTransition.swift
// Start → AutonomosLoadedSection+ReceiptStart.swift · Control → +ReceiptControl.swift

struct AutonomosRunReceiptLines: View {
    let model: AutonomosModel
    let reduceMotion: Bool

    var body: some View {
        Group {
            startRunReceiptLine
            transferReceiptLine
            controlReceiptLine
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: AutonomosLoadedSection.receiptPhaseID(for: model))
    }
}
