import SwiftUI
import AtlasCore
import Foundation
import UIKit

// GOD-RESTRUCTURE: ArenaRunSheet host+body fused

// MARK: - Host

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        suitesFormSection
        engineFormSection
        formGovernanceSections
    }

    @ViewBuilder
    var suitesFormSection: some View {
        section("Suítes") {
            if installedSuites.isEmpty {
                Text("nenhuma suite com adapter instalado")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
                    .accessibilityLabel(ArenaRunSheetJudgment.spokenEmptySuites())
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
                    .accessibilityIdentifier("arena-run-suite-\(suite.suite)")
                }
            }
        }
    }

    @ViewBuilder
    var engineFormSection: some View {
        section("Motores") {
            if engines.isEmpty {
                Text("nenhum motor publicado")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
                    .accessibilityLabel(ArenaRunSheetJudgment.spokenEmptyEngines())
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

    @ViewBuilder
    var formGovernanceSections: some View {
        section("Comparação") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                toggleRow(title: arm.labelPT, subtitle: armSubtitle(arm), isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        section("Governança") {
            fieldLabel("Operador")
            TextField("quem autoriza esta medição", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(ArenaRunSheetJudgment.actorHint)
            fieldLabel("Motivo")
            TextField("por que rodar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(ArenaRunSheetJudgment.reasonHint)
        }
    }

    func armSubtitle(_ arm: AtlasArenaRunArm) -> String {
        switch arm {
        case .baseline: "o motor puro, como referência"
        case .withAtlas: "os mesmos casos, com o Atlas"
        }
    }

    func fieldLabel(_ text: String) -> some View {
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
    /// WAVE-055: receipt chrome from ArenaStartJudgment.
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        let face = ArenaStartJudgment.receiptFace(receipt)
        return VStack(alignment: .leading, spacing: 6) {
            Text("recibo \(receipt.receiptHash)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
            Text(ArenaStartJudgment.receiptStatusLine(receipt))
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(
                    face.productWord == "worker_gap"
                        ? AtlasTheme.domOperacional
                        : AtlasTheme.accent
                )
                .accessibilityHidden(true)
            if model.lastStartEnginesCount > 1 {
                Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            if receipt.workerImplemented == false {
                Text(ArenaStartJudgment.workerGapCopy)
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaStartJudgment.spokenReceipt(receipt, enginesCount: model.lastStartEnginesCount, runsPlannedTotal: model.lastStartRunsPlannedTotal))
        .accessibilityValue(face.productWord)
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}

// MARK: - Body

// MARK: - Face

extension ArenaRunSheet {
    /// WAVE-074: exclusive run-sheet shell face.
    var runSheetFace: ArenaRunSheetFace {
        ArenaRunSheetJudgment.face(
            engineCount: engines.count,
            suiteCount: installedSuites.count
        )
    }

}

// MARK: - Section · toggle chrome

extension ArenaRunSheet {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ArenaPremiumKicker(text: title)
                .accessibilityAddTraits(.isHeader)
            content()
                .padding(.leading, 2)
        }
    }

    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ArenaPremiumIcon(
                    symbol: isOn ? "checkmark.circle" : "circle",
                    tone: isOn ? .active : .muted
                )
                .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    if let subtitle {
                        Text(subtitle)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
                Spacer()
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}

// MARK: - Host

struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    @State var selectedEngines: Set<String> = []
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            runScrollBody
        }
        .onAppear { seedDefaultsIfNeeded() }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
        .accessibilityLabel(ArenaRunSheetJudgment.spokenSheet(face: runSheetFace))
        .accessibilityValue(runSheetFace.productWord)
        .accessibilityHint(ArenaRunSheetJudgment.sheetHint)
    }

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
    var planPreview: some View {
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

    @ViewBuilder
    var statusBlocks: some View {
        if let error = model.controlError {
            Text(error)
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityLabel(ArenaRunSheetJudgment.spokenErrorLabel(error))
                .transition(reduceMotion ? .identity : .opacity)
        }
        if let receipt = model.lastStartReceipt {
            receiptCard(receipt)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
        }
    }

    var submitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(inputs: inputs) }
        } label: {
            Text("Rodar medição")
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(ArenaStartJudgment.submitFace(input: input, enginesEmpty: engines.isEmpty, suitesEmpty: installedSuites.isEmpty).spokenLabel)
        .accessibilityHint(ArenaStartJudgment.submitFace(input: input, enginesEmpty: engines.isEmpty, suitesEmpty: installedSuites.isEmpty).spokenHint)
    }

    @ToolbarContentBuilder
    var runToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaRunSheetJudgment.closeLabel,
                spokenHint: ArenaRunSheetJudgment.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }

    var engines: [String] {
        let catalog = model.engineCatalog?.engines.map(\.engine) ?? []
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(catalog + composite + suiteEngines)).sorted()
    }

    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }

    var input: AtlasArenaStartInput {
        payload(engine: selectedEngines.sorted().first ?? "")
    }

    var inputs: [AtlasArenaStartInput] {
        selectedEngines.sorted().map(payload(engine:))
    }

    func payload(engine: String) -> AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: engine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason,
            origin: UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        )
    }

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

// MARK: - ArenaSuiteSheet

// MARK: - Host

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCasesCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let cases = ArenaSuiteJudgment.casesCaption(for: engine) {
            Text(cases)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineDurationCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let duration = ArenaSuiteJudgment.durationCaption(for: engine) {
            Text(duration)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineHistorySparkline(_ engine: AtlasArenaSuiteEngine) -> some View {
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardCaptions(_ engine: AtlasArenaSuiteEngine) -> some View {
        engineCasesCaption(engine)
        engineDurationCaption(engine)
        engineHistorySparkline(engine)
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(ArenaDisplay.engine(engine.engine))
                    .font(AtlasFont.serif(21))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Índice da suíte · escala 0–10")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityHidden(true)
            Spacer()
            engineCardScore(engine)
        }
    }
}

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            engineCardHeader(engine)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
                VStack(alignment: .leading, spacing: 12) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
            }
            ArenaPremiumHairline()
            engineEvidence(engine)
            if !engine.history.isEmpty {
                ArenaPremiumKicker(text: "Histórico")
                engineHistorySparkline(engine)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteJudgment.spokenEngine(engine))
    }

    private func suiteMetric(
        _ label: String,
        _ value: Double?,
        signed: Bool = false,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))
                .font(AtlasFont.serif(29))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func engineEvidence(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let cases = ArenaSuiteJudgment.casesCaption(for: engine) {
                evidenceLine(cases, symbol: "checklist")
            }
            if let duration = ArenaSuiteJudgment.durationCaption(for: engine) {
                evidenceLine(duration, symbol: "timer")
            }
            evidenceLine("mesma suíte · braços equivalentes", symbol: "equal.circle")
        }
        .font(AtlasFont.mono(10))
        .foregroundStyle(AtlasTheme.textSecondary)
    }

    private func evidenceLine(_ text: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }

    private func pairedDelta(_ engine: AtlasArenaSuiteEngine) -> Double? {
        guard let withAtlas = engine.withAtlasScore,
              let withoutAtlas = engine.withoutAtlasScore else { return nil }
        return withAtlas - withoutAtlas
    }

    private func deltaTone(_ engine: AtlasArenaSuiteEngine) -> ArenaPremiumTone {
        guard let delta = pairedDelta(engine), abs(delta) > 0.005 else { return .neutral }
        return delta > 0 ? .positive : .negative
    }
}

// MARK: - Body

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(ArenaFormat.score(engine.score))
                .font(AtlasFont.serif(38))
            if engine.score != nil {
                Text("/10")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

extension ArenaSuiteSheet {
    /// WAVE-059: suite face + ranked engines.
    var suiteFace: ArenaSuiteFace {
        ArenaSuiteJudgment.face(for: suite)
    }

    var rankedEngines: [AtlasArenaSuiteEngine] {
        ArenaSuiteJudgment.rank(suite.engines)
    }

    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suiteFace.kicker,
                tone: suiteFace.productWord == "regression" ? .negative : .active
            )
            Text(ArenaDisplay.suite(suite.suite))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            HStack(spacing: 12) {
                metadata("\(suite.runsTotal) rodadas", symbol: "circle.grid.2x2")
                if let last = ArenaDisplay.relative(suite.lastRunAt) {
                    metadata(last, symbol: "clock")
                }
            }
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(ArenaSuiteJudgment.spokenSuite(suite))
        .accessibilityValue(suiteFace.productWord)
    }

    private func metadata(_ text: String, symbol: String) -> some View {
        HStack(spacing: 5) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }
}

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                suiteBodyTitle
                // WAVE-059: regressed engines first.
                ForEach(rankedEngines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text("Valores ausentes permanecem não medidos. Comparações só aparecem quando os dois braços foram publicados.")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Suite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}

extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        }
    }
}

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteJudgment.closeLabel,
                spokenHint: ArenaSuiteJudgment.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}
