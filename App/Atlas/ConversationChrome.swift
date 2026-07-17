import SwiftUI
import AtlasCore

// Shell compartilhado dos sheets do composer.
// Turno editorial → EditorialTurn.swift; strip → DraftStrip.swift.
// Seletores → ConversationChrome+ComposerSheets.swift.

// MARK: - Sheets (seletores funcionais, tema Atlas)

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
                .accessibilityHidden(true)
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .padding(.bottom, 14)
                .accessibilityAddTraits(.isHeader)
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .presentationDragIndicator(.hidden)
    }
}

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    var accessibilityLabel: String? = nil
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    if let sub {
                        Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AtlasTheme.accent)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            accessibilityLabel ?? SheetShellA11y.spokenRow(label: label, sub: sub, selected: selected)
        )
        .accessibilityHint(accessibilityHint ?? "")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .modifier(OptionalAccessibilityIdentifier(accessibilityIdentifier))
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

private struct OptionalAccessibilityIdentifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}
