import AtlasCore
import SwiftUI
import UIKit

// Cycle 026 fuse → ArenaRunSheet+Form.swift

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        suitesFormSection
        engineFormSection
        formGovernanceSections
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormEmpty: some View {
        Text("nenhum motor publicado")
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
            .accessibilityLabel(spokenEmptyEngines())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormSection: some View {
        section("Motores") {
            if engines.isEmpty {
                engineFormEmpty
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(
                        title: ArenaDisplay.engine(engine),
                        subtitle: nil,
                        isOn: selectedEngines.contains(engine)
                    ) {
                        if selectedEngines.contains(engine) {
                            selectedEngines.remove(engine)
                        } else {
                            selectedEngines.insert(engine)
                        }
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
                if engines.count > 1 {
                    Text("Escolha 2 ou mais para comparar motor contra motor.")
                        .font(.system(.caption))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var formGovernanceSections: some View {
        section("Comparação") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                // Sublinha humana — "baseline"/"with_atlas" era slug de
                // máquina vazando na UI (canon: sem slug cru).
                toggleRow(title: arm.labelPT, subtitle: armSubtitle(arm), isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        governanceFields
    }

    func armSubtitle(_ arm: AtlasArenaRunArm) -> String {
        switch arm {
        case .baseline: "o motor puro, como referência"
        case .withAtlas: "os mesmos casos, com o Atlas"
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var governanceFields: some View {
        section("Governança") {
            // Campos na identidade da casa — .roundedBorder rendia caixas
            // BRANCAS no dark (a maior quebra da folha); rótulo diz o que é.
            fieldLabel("Operador")
            TextField("quem autoriza esta medição", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(spokenActorHint())
            fieldLabel("Motivo")
            TextField("por que rodar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(spokenReasonHint())
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
    }
}

struct ArenaFieldChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                    .fill(AtlasTheme.bgRecessed)
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var suitesFormSection: some View {
        section("Suítes") {
            if installedSuites.isEmpty {
                suitesEmptyLabel
            } else {
                suitesToggleRows
            }
        }
    }
}

extension ArenaRunSheet {
    var suitesEmptyLabel: some View {
        Text("nenhuma suite com adapter instalado")
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
            .accessibilityLabel(spokenEmptySuites())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    var suitesToggleRows: some View {
        ForEach(installedSuites) { suite in
            toggleRow(
                title: suite.suite,
                subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "não medido",
                isOn: selectedSuites.contains(suite.suite)
            ) {
                if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                else { selectedSuites.insert(suite.suite) }
            }
            .accessibilityIdentifier("arena-run-suite-\(suite.suite)")
        }
    }
}

extension ArenaRunSheet {
    /// Catálogo B6 (motores rodáveis, inclusive nunca medidos) ∪ já medidos.
    var engines: [String] {
        let catalog = model.engineCatalog?.engines.map(\.engine) ?? []
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(catalog + composite + suiteEngines)).sorted()
    }
}

extension ArenaRunSheet {
    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }
}

extension ArenaRunSheet {
    /// Representativo (validação/A11y) — mesmos campos de todos os POSTs.
    var input: AtlasArenaStartInput {
        payload(engine: selectedEngines.sorted().first ?? "")
    }

    /// Um POST B5 por motor selecionado (goal 1: motor contra motor).
    var inputs: [AtlasArenaStartInput] {
        selectedEngines.sorted().map(payload(engine:))
    }

    private func payload(engine: String) -> AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: engine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason,
            origin: UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        )
    }
}

extension ArenaRunSheet {
    var submitButtonLabel: some View {
        Text("Rodar medição")
            .font(.system(.body, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
    }
}

extension ArenaRunSheet {
    var submitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(inputs: inputs) }
        } label: {
            submitButtonLabel
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(spokenSubmitLabel(input: input, enginesEmpty: engines.isEmpty))
        .accessibilityHint(spokenSubmitHint(input: input, enginesEmpty: engines.isEmpty))
    }
}
