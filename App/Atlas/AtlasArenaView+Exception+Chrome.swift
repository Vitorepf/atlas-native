import SwiftUI
import AtlasCore

// Exception chrome — peel de AtlasArenaView+Exception.

extension AtlasArenaView {
    func exceptionBannerChrome(_ row: some View, text: String) -> some View {
        row
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).fill(AtlasTheme.alert.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.alert.opacity(0.35), lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("regressão, \(text)")
    }
}
