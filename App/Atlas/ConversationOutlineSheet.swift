import SwiftUI
import AtlasCore

// IDLE-COMPRESS peel ConversationOutline sheet/row (canon §7 · WAVE-079 domain)

// MARK: - Índice da conversa (fusão idle dos peels Outline*)

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]
    var reduceMotion: Bool = false

    var body: some View {
        outlineA11yBind(
            SheetShell(title: "Índice da conversa") {
                outlineSheetContent
            }
        )
    }

    func outlineA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.conversationOutlineSheet)
            .accessibilityLabel(ConversationOutlineJudgment.spokenSheetLabel(turnCount: bubbles.count))
            .accessibilityValue(
                ConversationOutlineJudgment.face(turnCount: bubbles.count).productWord
            )
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }

    @ViewBuilder
    var outlineSheetContent: some View {
        if bubbles.isEmpty {
            outlineEmpty
        } else {
            outlineRowList
        }
    }

    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineJudgment.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
    }

    @ViewBuilder
    var outlineRowList: some View {
        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
            ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble
    var reduceMotion: Bool = false

    var body: some View {
        outlineLead
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 10)
            .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                ConversationOutlineJudgment.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }

    var snippet: String {
        ConversationOutlineJudgment.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }

    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.accent)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }

    var outlineLeadSnippetStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            outlineLeadRole
            Text(snippet)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}


