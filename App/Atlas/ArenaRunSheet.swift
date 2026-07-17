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

    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }

    var engines: [String] {
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(composite + suiteEngines)).sorted()
    }

    var input: AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: selectedEngine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason
        )
    }

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

                    Button {
                        Task { await model.startRuns(input: input) }
                    } label: {
                        Text("Rodar medição")
                            .font(.system(.body, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
                            .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                    }
                    .buttonStyle(PressableScale())
                    .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .disabled(!input.isLocallyValidForSubmission)
                    .accessibilityIdentifier(A11yID.arenaRunSubmit)
                    .accessibilityLabel(spokenSubmitLabel(input: input, enginesEmpty: engines.isEmpty))
                    .accessibilityHint(spokenSubmitHint(input: input, enginesEmpty: engines.isEmpty))
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
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .onAppear {
            if selectedSuites.isEmpty, let first = installedSuites.first?.suite {
                selectedSuites.insert(first)
            }
            if engines.isEmpty {
                selectedEngine = ""
            } else if selectedEngine.isEmpty {
                selectedEngine = engines.first ?? ""
            }
        }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
    }
}
