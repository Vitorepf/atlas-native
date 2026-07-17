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
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).padding(.bottom, 14)
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
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    if let sub { Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary) }
                }
                Spacer()
                if selected { Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.accent) }
            }
            .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}
