import SwiftUI
import AtlasCore

/// Remove — peel de DraftThumb (régua ≤100).
/// Veil → DraftThumb+ChromeVeil.swift

extension DraftThumb {
    @ViewBuilder var removeButton: some View {
        if draft.state != .subindo {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRemove(draft.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
                    .padding(8)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .offset(x: 12, y: -12)
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
        }
    }
}
