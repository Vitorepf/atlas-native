import SwiftUI
import AtlasCore

struct ArenaPremiumStopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let run: AtlasArenaLiveRun
    @State private var actor = ""
    @State private var reason = ""

    private var valid: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isConfirmed: Bool {
        model.lastStopReceipt?.measurementIdPublic == run.measurementIdPublic
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ArenaPremiumEmptyGlyph(symbol: "stop.circle", tone: .negative)
                    ArenaPremiumKicker(text: "Ação governada", tone: .negative)
                        .accessibilityIdentifier(A11yID.arenaPremiumStopSheet)
                    Text("Parar a medição?")
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text("O caso atual termina antes da parada. Casos concluídos e resultados parciais são preservados.")
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
            .navigationTitle("Parar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar confirmação",
                        spokenHint: "mantém a medição em execução",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
        }
        .onAppear { model.controlError = nil }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Chrome da casa: .roundedBorder rendia caixas BRANCAS no dark
            // (a mesma quebra já corrigida na folha de rodar) — ink neutro.
            fieldLabel("Operador")
            TextField("quem autoriza esta parada", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopActor)
            fieldLabel("Motivo")
            TextField("por que parar agora (fica no recibo)", text: $reason, axis: .vertical)
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
                Text(model.isStoppingMeasurement ? "Solicitando…" : "Parar após o caso atual")
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
    }
}
