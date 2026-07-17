import SwiftUI
import AtlasCore

// Run form scroll — peel de ArenaRunSheet.

extension ArenaRunSheet {
    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                formSections
                statusBlocks
                submitButton
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Rodar medição")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { runToolbar }
    }
}
