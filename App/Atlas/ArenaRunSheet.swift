import AtlasCore
import SwiftUI

// Cycle 026 fuse → ArenaRunSheet.swift

extension ArenaRunSheet {
    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    ArenaPremiumKicker(text: "Nova medição", tone: .active)
                    Text("O que vamos medir?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("Escolha somente o necessário. A ordem e o progresso aparecem na Arena assim que o servidor confirmar.")
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                formSections
                planPreview
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

    @ViewBuilder
    private var planPreview: some View {
        if !selectedSuites.isEmpty, !selectedEngines.isEmpty, !selectedArms.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ArenaPremiumKicker(text: "Plano")
                Text(
                    "\(selectedEngines.count) \(selectedEngines.count == 1 ? "motor" : "motores") · "
                        + "\(selectedSuites.count) \(selectedSuites.count == 1 ? "suíte" : "suítes") · "
                        + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas"
                )
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                Text(selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: " → "))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.vertical, 4)
        }
    }
}

struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    /// Multi-select (goal 1: motor contra motor) — cada motor vira um POST B5.
    @State var selectedEngines: Set<String> = []
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        runSheetA11y(runNavShell)
    }
}

extension ArenaRunSheet {
    var runNavShell: some View {
        NavigationStack {
            runScrollBody
        }
    }
}

extension ArenaRunSheet {
    @ToolbarContentBuilder
    var runToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: spokenCloseLabel(),
                spokenHint: spokenCloseHint(),
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ArenaRunSheet {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ArenaPremiumKicker(text: title)
                .accessibilityAddTraits(.isHeader)
            content()
                .padding(.leading, 2)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var statusBlocks: some View {
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
    }
}

extension ArenaRunSheet {
    func seedDefaultsIfNeeded() {
        if selectedSuites.isEmpty, let first = installedSuites.first?.suite {
            selectedSuites.insert(first)
        }
        if engines.isEmpty {
            selectedEngines = []
        } else if selectedEngines.isEmpty, let first = engines.first {
            selectedEngines = [first]
        }
    }
}
