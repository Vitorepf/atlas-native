import SwiftUI
import AtlasCore

struct ArenaPremiumStopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let run: AtlasArenaLiveRun
    @State private var actor = ""
    @State private var reason = ""

    private var stopFace: ArenaStopFace {
        ArenaStopJudgment.face(actor: actor, reason: reason)
    }

    private var valid: Bool {
        ArenaStopJudgment.canSubmit(actor: actor, reason: reason)
    }

    private var isConfirmed: Bool {
        model.lastStopReceipt?.measurementIdPublic == run.measurementIdPublic
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ArenaPremiumEmptyGlyph(symbol: "stop.circle", tone: .negative)
                    ArenaPremiumKicker(text: ArenaStopJudgment.kicker, tone: .negative)
                        .accessibilityIdentifier(A11yID.arenaPremiumStopSheet)
                    Text(ArenaStopJudgment.heroTitle)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(ArenaStopJudgment.bodyCopy)
                        .font(.system(.body))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    fields
                    receipt
                    confirm
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(ArenaStopJudgment.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: ArenaStopJudgment.closeSpoken,
                        spokenHint: ArenaStopJudgment.closeHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                ArenaStopJudgment.spokenSheet(
                    actor: actor,
                    reason: reason,
                    suite: ArenaDisplay.suite(run.suite)
                )
            )
            .accessibilityValue(stopFace.productWord)
        }
        .onAppear { model.controlError = nil }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Chrome da casa: .roundedBorder rendia caixas BRANCAS no dark
            // (a mesma quebra já corrigida na folha de rodar) — ink neutro.
            fieldLabel(ArenaStopJudgment.actorLabel)
            TextField(ArenaStopJudgment.actorPlaceholder, text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopActor)
            fieldLabel(ArenaStopJudgment.reasonLabel)
            TextField(ArenaStopJudgment.reasonPlaceholder, text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopReason)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
    }

    @ViewBuilder
    private var receipt: some View {
        if let value = model.lastStopReceipt,
           value.measurementIdPublic == run.measurementIdPublic {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    value.accepted ? "Solicitação confirmada" : "Medição já havia terminado",
                    systemImage: value.accepted ? "checkmark.seal" : "info.circle"
                )
                    .font(.system(.callout, weight: .semibold))
                    .foregroundStyle(value.accepted ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                Text(value.stopsAfterCurrentCase ? "parada após o caso atual" : value.status.rawValue)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumStopReceipt)
            .accessibilityLabel(ArenaStopJudgment.spokenReceipt(value))
        }
        if let error = model.controlError {
            Text(error)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.alert)
        }
    }

    private var confirm: some View {
        Button {
            guard let measurementId = run.measurementIdPublic else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await model.stopMeasurement(
                    measurementId: measurementId,
                    operatorActor: actor,
                    operatorReason: reason
                )
            }
        } label: {
            HStack(spacing: 9) {
                ArenaPremiumIcon(
                    symbol: ArenaPremiumIconography.stop,
                    tone: valid && !isConfirmed ? .negative : .muted
                )
                Text(model.isStoppingMeasurement ? "Solicitando…" : ArenaStopJudgment.confirmTitle)
            }
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(valid && !isConfirmed ? AtlasTheme.alert : AtlasTheme.textTertiary)
                .background(Capsule().fill(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.08 : 0.03)))
                .overlay(Capsule().stroke(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.5 : 0.15), lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .disabled(!valid || model.isStoppingMeasurement || isConfirmed)
        .accessibilityIdentifier(A11yID.arenaPremiumStopConfirm)
        .accessibilityLabel(ArenaStopJudgment.spokenConfirm(actor: actor, reason: reason))
        .accessibilityHint(ArenaStopJudgment.confirmHint)
    }
}
