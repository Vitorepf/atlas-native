import SwiftUI
import AtlasCore

// Cycle 021 fuse → ConversationChrome.swift

struct OptionalAccessibilityIdentifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}

extension SheetShell {
    var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
            .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            .accessibilityHidden(true)
    }

    var sheetTitle: some View {
        Text(title)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 14)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SheetShell {
    func sheetPresentationChrome<Inner: View>(_ content: Inner) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationBackground(AtlasTheme.bg)
            .presentationDragIndicator(.hidden)
    }
}

extension SheetShell {
    var sheetScrollBody: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
    }
}

/// Rótulo composto só com label/sub publicados; seleção explícita.

enum SheetShellA11y {
    static func spokenRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }
}

// Shell compartilhado dos sheets do composer.

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        sheetPresentationChrome(sheetScrollBody)
    }
}
