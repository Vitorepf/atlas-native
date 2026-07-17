import SwiftUI
import AtlasCore

// Phase ID → AutonomosLoadedSection+ReceiptPhaseID.swift

extension AutonomosLoadedSection {
    @ViewBuilder
    var runReceiptLines: some View {
        AutonomosRunReceiptLines(model: model, reduceMotion: reduceMotion)
    }
}
