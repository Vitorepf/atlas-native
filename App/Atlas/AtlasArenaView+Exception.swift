import SwiftUI
import AtlasCore

// Banner de regressão — peel de AtlasArenaView+Failure.

extension AtlasArenaView {
    func exceptionBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
            Text(text)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.alert.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.alert.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("regressão, \(text)")
    }
}
