import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Outline Judgment + Sheet fused

// MARK: - Judgment

// MARK: - Types

/// Exclusive conversation outline face (WAVE-079).
enum ConversationOutlineFace: Equatable {
    case empty
    case turns(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .turns: return "turns"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "sem turnos carregados nesta thread"
        case .turns(let n):
            let noun = n == 1 ? "turno" : "turnos"
            return "\(n) \(noun)"
        }
    }
}

// MARK: - Judgment

/// Pure conversation-outline grammar — face · spoken · pack.
enum ConversationOutlineJudgment {

    static func face(turnCount: Int) -> ConversationOutlineFace {
        turnCount <= 0 ? .empty : .turns(turnCount)
    }

    static func spokenSheetLabel(turnCount: Int) -> String {
        let face = face(turnCount: turnCount)
        switch face {
        case .empty:
            return "índice da conversa, \(face.spokenFace)"
        case .turns:
            return "índice da conversa, \(face.spokenFace)"
        }
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }

    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }

    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(spokenRole(role)), \(snippet)"
    }

    static func packFacts(turnCount: Int) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(turnCount: turnCount)
        facts.append("outline_face: \(face.productWord)")
        switch face {
        case .empty:
            absences.append("índice sem turnos nesta thread")
            facts.append("outline_turns: 0")
        case .turns(let n):
            facts.append("outline_turns: \(n)")
        }
        return (facts, absences)
    }

    // MARK: Chrome spoken (IDLE · was ConversationViewA11y outline)

    static func spokenOutlineControl(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static let outlineControlHint = "abre o índice editorial dos turnos desta conversa"
}

// MARK: - Sheet

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
