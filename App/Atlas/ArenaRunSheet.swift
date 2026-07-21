import AtlasCore
import Foundation
import SwiftUI
import UIKit

// Cycle 044 fuse → ArenaRunSheet.swift

extension ArenaRunSheet {
    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    ArenaPremiumKicker(text: "Nova medição", tone: .active)
                    Text("O que vamos medir?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Plano, \(selectedEngines.count) motores, \(selectedSuites.count) suítes, "
                    + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas, "
                    + selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: ", ")
            )
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
            .onChange(of: model.lastStartReceipt?.receiptHash) { _, hash in
                guard hash != nil else { return }
                AtlasMotion.successNotification(reduceMotion: reduceMotion)
            }
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

extension ArenaRunSheet {
    func spokenSubmitLabel(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return spokenSubmitValid()
        }
        if enginesEmpty {
            return spokenSubmitEnginesEmpty()
        }
        return spokenSubmitMissing(input: input)
    }
}

extension ArenaRunSheet {
    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }
}

extension ArenaRunSheet {
    func spokenEnginesCount() -> String {
        if engines.isEmpty {
            return "nenhum motor publicado"
        }
        return "\(engines.count) motor\(engines.count == 1 ? "" : "es")"
    }
}

extension ArenaRunSheet {
    func spokenErrorLabel(_ message: String) -> String {
        "erro: \(message)"
    }
}

extension ArenaRunSheet {
    func spokenSubmitHint(input: AtlasArenaStartInput, enginesEmpty: Bool) -> String {
        if input.isLocallyValidForSubmission {
            return "envia medição governada ao servidor"
        }
        if enginesEmpty {
            return "aguarde o servidor publicar pelo menos um motor"
        }
        return "preencha ator, motivo, suites, motor e braços"
    }
}

extension ArenaRunSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza a medição"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingOperator(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.operatorActor.isEmpty { missing.append("ator") }
        if input.operatorReason.isEmpty { missing.append("motivo auditável") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissingSuite(input: AtlasArenaStartInput) -> [String] {
        var missing: [String] = []
        if input.suites.selectedValues.isEmpty { missing.append("suites") }
        if input.engine.isEmpty { missing.append("motor") }
        if input.arms.isEmpty { missing.append("braços") }
        return missing
    }
}

extension ArenaRunSheet {
    func spokenSubmitMissing(input: AtlasArenaStartInput) -> String {
        let missing = spokenSubmitMissingOperator(input: input)
            + spokenSubmitMissingSuite(input: input)
        if missing.isEmpty { return "rodar medição indisponível" }
        return "rodar medição indisponível, falta \(missing.joined(separator: ", "))"
    }
}

extension ArenaRunSheet {
    func spokenReceiptLabel(_ receipt: AtlasArenaStartReceipt) -> String {
        var parts = ["recibo \(receipt.receiptHash)"]
        parts.append(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
        if receipt.workerImplemented == false {
            parts.append("worker de medição ainda não implementado")
        }
        return parts.joined(separator: ", ")
    }
}

extension ArenaRunSheet {
    func spokenCloseLabel() -> String { "fechar folha de medição" }

    func spokenCloseHint() -> String { "volta para a Arena sem enviar" }
}

extension ArenaRunSheet {
    func spokenSheetHint() -> String {
        "escolhe suites, motor e braços; ator e motivo auditáveis são obrigatórios"
    }
}

extension ArenaRunSheet {
    func spokenSheetLabel() -> String {
        var parts = ["rodar medição Arena"]
        parts.append(spokenEnginesCount())
        parts.append(spokenSuitesCount())
        return parts.joined(separator: ", ")
    }
}

extension ArenaRunSheet {
    func spokenSubmitEnginesEmpty() -> String {
        "rodar medição indisponível, nenhum motor publicado"
    }
}

extension ArenaRunSheet {
    func spokenSubmitValid() -> String {
        "rodar medição"
    }
}

extension ArenaRunSheet {
    func spokenSuitesCount() -> String {
        let suites = installedSuites.count
        if suites == 0 {
            return "nenhuma suite com adapter"
        }
        return "\(suites) suite\(suites == 1 ? "" : "s") instalada\(suites == 1 ? "" : "s")"
    }
}

extension ArenaRunSheet {
    func runSheetA11y<V: View>(_ content: V) -> some View {
        content
            .onAppear { seedDefaultsIfNeeded() }
            .accessibilityIdentifier(A11yID.arenaRunSheet)
            .accessibilityLabel(spokenSheetLabel())
            .accessibilityHint(spokenSheetHint())
    }
}

extension ArenaRunSheet {
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            receiptCardCopy(receipt)
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenReceiptLabel(receipt))
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptHashCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text("recibo \(receipt.receiptHash)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .truncationMode(.middle)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptStatusCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        Text(receipt.isEnqueued ? "na fila, ainda não iniciado" : receipt.status)
            .font(.system(.callout, weight: .semibold))
            .foregroundStyle(AtlasTheme.accent)
            .accessibilityHidden(true)
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptWorkerGapCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        if receipt.workerImplemented == false {
            // false hoje = worker desligado no servidor (ATLAS_ARENA_WORKER_ENABLED).
            Text("worker de medição desligado no servidor — fila aguardando")
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func receiptCardCopy(_ receipt: AtlasArenaStartReceipt) -> some View {
        receiptHashCopy(receipt)
        receiptStatusCopy(receipt)
        receiptMultiEngineCopy
        receiptWorkerGapCopy(receipt)
    }

    /// Agregado do start multi-motor (goal 1) — só quando houve 2+ POSTs.
    @ViewBuilder
    var receiptMultiEngineCopy: some View {
        if model.lastStartEnginesCount > 1 {
            Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ArenaRunSheet {
    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        } label: {
            toggleLabel(title: title, subtitle: subtitle, isOn: isOn)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityHint(isOn ? "desmarca esta opção" : "marca esta opção")
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

extension ArenaRunSheet {
    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelSymbol(isOn: Bool) -> some View {
        ArenaPremiumIcon(
            symbol: isOn ? "checkmark.circle" : "circle",
            tone: isOn ? .active : .muted
        )
            .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelTitleStack(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            toggleSubtitle(subtitle)
        }
    }
}

extension ArenaRunSheet {
    func toggleLabel(title: String, subtitle: String?, isOn: Bool) -> some View {
        HStack(spacing: 10) {
            toggleLabelSymbol(isOn: isOn)
            toggleLabelTitleStack(title: title, subtitle: subtitle)
            Spacer()
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

extension ArenaRunSheet {
    @ViewBuilder
    func toggleSubtitle(_ subtitle: String?) -> some View {
        if let subtitle {
            Text(subtitle)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

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
                .modifier(ArenaFieldChrome(minHeight: 88))
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(spokenReasonHint())
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }
}

struct ArenaFieldChrome: ViewModifier {
    /// Single-line 48; multi-line reason fields pass 88.
    var minHeight: CGFloat = 48

    func body(content: Content) -> some View {
        content
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .frame(
                minHeight: minHeight,
                alignment: minHeight > 48 ? .topLeading : .center
            )
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
            .contentShape(Capsule())
    }
}

extension ArenaRunSheet {
    var submitButton: some View {
        Button {
            // Medium: primary run commit (not tab/navigation soft).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
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
