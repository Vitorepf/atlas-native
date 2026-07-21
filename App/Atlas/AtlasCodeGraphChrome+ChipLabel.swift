import SwiftUI
import AtlasCore

// Filter tabs — sublinhado dourado (AX v4), não cluster de chips.

extension AtlasCodeView {
    func graphStateChipLabel(_ option: AtlasCodeGraphStateFilter, count: Int, active: Bool) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 3) {
                Text(option.label)
                    .atlasSans(11.5, .medium)
                Text("\(count)")
                    .font(AtlasFont.mono(10))
                    .opacity(0.55)
            }
            .foregroundStyle(tabForeground(option, active: active))
            .monospacedDigit()

            Rectangle()
                .fill(active ? tabUnderline(option) : Color.clear)
                .frame(height: 1.5)
                .shadow(color: active ? tabUnderline(option).opacity(0.35) : .clear, radius: 4, y: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
    }

    private func tabForeground(_ option: AtlasCodeGraphStateFilter, active: Bool) -> Color {
        guard active else { return AtlasTheme.textTertiary }
        return option == .violating ? AtlasCodePalette.alert : AtlasTheme.textPrimary
    }

    private func tabUnderline(_ option: AtlasCodeGraphStateFilter) -> Color {
        option == .violating ? AtlasCodePalette.alert : AtlasTheme.accent
    }
}
