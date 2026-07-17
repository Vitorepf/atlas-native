import SwiftUI
import AtlasCore

/// Remove — peel de DraftThumb (régua ≤100).
/// Veil → DraftThumb+ChromeVeil.swift
/// Button → DraftThumb+Chrome+Button.swift
/// A11y → DraftThumb+Chrome+A11y.swift

extension DraftThumb {
    @ViewBuilder var removeButton: some View {
        if draft.state != .subindo {
            removeButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRemove(draft.id)
                } label: {
                    removeButtonChrome
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
            )
        }
    }
}
