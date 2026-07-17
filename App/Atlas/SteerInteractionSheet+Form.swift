import SwiftUI
import AtlasCore

/// Form body — peel de SteerInteractionSheet (régua ≤100).

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Redirecionar")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("A instrução entra no próximo checkpoint seguro desta execução. O Atlas pode recusar e devolver o motivo público.")
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Picker("Escopo", selection: $scope) {
                ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                    Text(scope.rawValue).tag(scope)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier(A11yID.steerScope)
            .accessibilityLabel(spokenScopeLabel(scope))
            TextField("O que muda a partir daqui?", text: $instruction, axis: .vertical)
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textPrimary)
                .tint(AtlasTheme.accent)
                .lineLimit(3...7)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separator, lineWidth: 1))
                .accessibilityIdentifier(A11yID.steerInstruction)
                .accessibilityHint("descreve o que deve mudar na execução")
            if let receipt = matchedReceipt {
                receiptLine(receipt)
                    .transition(reduceMotion ? .identity : .opacity)
                    .accessibilityIdentifier(A11yID.steerReceipt)
                    .accessibilityLabel(spokenReceiptLabel(receipt))
            }
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}
