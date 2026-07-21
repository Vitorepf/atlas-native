import AtlasCore
import Foundation
import SwiftUI
import UIKit

// IDLE-COMPRESS ArenaRunSheet fused

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

