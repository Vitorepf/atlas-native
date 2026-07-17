import SwiftUI
import AtlasCore

struct SteerInteractionSheet: View {
    let traceId: TraceID
    let receipt: AtlasInteractionSteerResponse?
    let onSubmit: (String, AtlasInteractionSteerScope) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var instruction = ""
    @State private var scope: AtlasInteractionSteerScope = .currentStep

    private var canSubmit: Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    Text("Redirecionar")
                        .font(AtlasFont.serif(24, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)

                    Text("A instrução entra no próximo checkpoint seguro desta execução. O Atlas pode recusar e devolver o motivo público.")
                        .font(.footnote)
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Picker("Escopo", selection: $scope) {
                        ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                            Text(scope.rawValue).tag(scope)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier(A11yID.steerScope)

                    TextField("O que muda a partir daqui?", text: $instruction, axis: .vertical)
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent)
                        .lineLimit(3...7)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separator, lineWidth: 1))
                        .accessibilityIdentifier(A11yID.steerInstruction)

                    if let receipt {
                        receiptLine(receipt)
                            .accessibilityIdentifier(A11yID.steerReceipt)
                    }

                    Spacer(minLength: 0)
                }
                .padding(22)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enviar") {
                        onSubmit(instruction, scope)
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.steerSubmit)
                }
            }
        }
        .accessibilityIdentifier(A11yID.steerSheet)
        .accessibilityLabel("redirecionar execução \(traceId.rawValue)")
    }

    private func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        let text = receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"

        return Text(text)
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
