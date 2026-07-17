import SwiftUI
import AtlasCore

struct ArenaRunSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: ArenaModel
    @State private var selectedSuites: Set<String> = []
    @State private var selectedEngine: String = ""
    @State private var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State private var actor = ""
    @State private var reason = ""

    private var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }

    private var engines: [String] {
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(composite + suiteEngines)).sorted()
    }

    private var input: AtlasArenaStartInput {
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
                    section("SUITES COM ADAPTER") {
                        if installedSuites.isEmpty {
                            Text("nenhuma suite com adapter instalado")
                                .font(.system(.subheadline))
                                .foregroundStyle(AtlasTheme.textTertiary)
                        } else {
                            ForEach(installedSuites) { suite in
                                toggleRow(
                                    title: suite.suite,
                                    subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "não medido",
                                    isOn: selectedSuites.contains(suite.suite)
                                ) {
                                    if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                                    else { selectedSuites.insert(suite.suite) }
                                }
                            }
                        }
                    }

                    section("MOTOR") {
                        ForEach(engines, id: \.self) { engine in
                            toggleRow(title: engine, subtitle: nil, isOn: selectedEngine == engine) {
                                selectedEngine = engine
                            }
                        }
                    }

                    section("BRAÇOS") {
                        ForEach(AtlasArenaRunArm.allCases) { arm in
                            toggleRow(title: arm.labelPT, subtitle: arm.rawValue, isOn: selectedArms.contains(arm)) {
                                if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                                else { selectedArms.insert(arm) }
                            }
                        }
                    }

                    section("GOVERNANÇA") {
                        TextField("ator", text: $actor)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier(A11yID.arenaRunActor)
                        TextField("motivo auditável", text: $reason, axis: .vertical)
                            .lineLimit(2...4)
                            .accessibilityIdentifier(A11yID.arenaRunReason)
                    }
                    .textFieldStyle(.roundedBorder)

                    if let error = model.controlError {
                        Text(error)
                            .font(.system(.callout))
                            .foregroundStyle(AtlasTheme.alert)
                    }

                    if let receipt = model.lastStartReceipt {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("recibo \(receipt.receiptHash)")
                                .font(AtlasFont.mono(11))
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
                                .font(.system(.callout, weight: .semibold))
                                .foregroundStyle(AtlasTheme.accent)
                            if receipt.workerImplemented == false {
                                Text("worker de medição ainda não implementado")
                                    .font(.system(.caption))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                        }
                        .padding(14)
                        .atlasCard()
                        .accessibilityIdentifier(A11yID.arenaRunReceipt)
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
                    .buttonStyle(.plain)
                    .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
                    .disabled(!input.isLocallyValidForSubmission)
                    .accessibilityIdentifier(A11yID.arenaRunSubmit)
                }
                .padding(AtlasTheme.Space.screen)
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
            if selectedEngine.isEmpty {
                selectedEngine = engines.first ?? ""
            }
        }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.caption, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            content()
        }
    }

    private func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isOn ? AtlasTheme.accent : AtlasTheme.textTertiary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
