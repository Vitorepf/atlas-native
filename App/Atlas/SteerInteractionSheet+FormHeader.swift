import AtlasCore
import SwiftUI

// Cycle 039 fuse → SteerInteractionSheet+FormHeader.swift

extension SteerInteractionSheet {
    var formHeader: some View {
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
            formScopePicker
        }
    }
}
