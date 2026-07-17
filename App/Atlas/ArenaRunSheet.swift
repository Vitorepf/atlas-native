import SwiftUI
import AtlasCore

struct ArenaRunSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    @State var selectedEngine: String = ""
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    formSections
                    if let error = model.controlError {
                        Text(error)
                            .font(.system(.callout))
                            .foregroundStyle(AtlasTheme.alert)
                            .accessibilityLabel(spokenErrorLabel(error))
                            .transition(reduceMotion ? .identity : .opacity)
                    }
                    if let receipt = model.lastStartReceipt {
                        receiptCard(receipt)
                            .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
                    }
                    submitButton
                }
                .padding(AtlasTheme.Space.screen)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
                .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Rodar medição")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: spokenCloseLabel(),
                        spokenHint: spokenCloseHint(),
                        reduceMotion: reduceMotion
                    ) { dismiss() }                }
            }
        }
        .onAppear { seedDefaultsIfNeeded() }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
        .accessibilityLabel(spokenSheetLabel())
        .accessibilityHint(spokenSheetHint())
    }
}
