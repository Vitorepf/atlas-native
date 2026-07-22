import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: density split — outline/stale

// MARK: - ConversationOutlineJudgments

// MARK: - ConversationOutlineJudgment

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

    static let productNoTurnsLoaded = "Nenhum turno carregado nesta thread."

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

    static let spokenOutlineControlHint = "abre o índice editorial dos turnos desta conversa"
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
        Text(ConversationOutlineJudgment.productNoTurnsLoaded)
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

// MARK: - ConversationStaleReadJudgment

// MARK: - Judgment

// MARK: - Types

/// Exclusive cache-read honesty face (WAVE-060).
enum ConversationStaleReadFace: Equatable {
    case confirming
    case fresh
    case aged
    case stale

    var productWord: String {
        switch self {
        case .confirming: return "confirming"
        case .fresh: return "fresh"
        case .aged: return "aged"
        case .stale: return "stale"
        }
    }

    var spokenFace: String {
        switch self {
        case .confirming: return "histórico salvo atualizado"
        case .fresh: return "leitura recente em cache"
        case .aged: return "leitura envelhecendo em cache"
        case .stale: return "leitura envelhecida em cache"
        }
    }
}

// MARK: - Judgment

/// Pure stale-read seal grammar — face · caption · spoken · pack.
enum ConversationStaleReadJudgment {

    /// Fresh < 5m · aged < 1h · stale ≥ 1h (display buckets only).
    static func face(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool
    ) -> ConversationStaleReadFace {
        if confirming { return .confirming }
        let seconds = max(0, Int(now.timeIntervalSince(capturedAt)))
        if seconds < 5 * 60 { return .fresh }
        if seconds < 60 * 60 { return .aged }
        return .stale
    }

    static func displayCaption(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }

    static func spokenLabel(
        capturedAt: Date,
        now: Date = Date(),
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        let age = atlasRelativeAgePT(since: capturedAt, now: now)
        return "histórico salvo visto há \(age), \(face.spokenFace)"
    }

    static func packFacts(
        capturedAt: Date?,
        now: Date = Date(),
        confirming: Bool = false
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let capturedAt else {
            absences.append("sem captura de cache neste recorte")
            return (facts, absences)
        }
        let face = face(capturedAt: capturedAt, now: now, confirming: confirming)
        facts.append("stale_read_face: \(face.productWord)")
        facts.append("cache_age_s: \(max(0, Int(now.timeIntervalSince(capturedAt))))")
        if confirming {
            facts.append("cache_confirming: true")
        }
        return (facts, absences)
    }
}

// MARK: - Seal chrome

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ConversationStaleReadJudgment.spokenLabel(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
    }
}

extension StaleReadSeal {
    func sealCaptionRow(now: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(ConversationStaleReadJudgment.displayCaption(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
            .font(AtlasFont.mono(11))
            .modifier(NumericTextTransition(enabled: !reduceMotion && !confirming))
            .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealChrome(now: Date) -> some View {
        sealCaptionRow(now: now)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
    }
}


extension StaleReadSeal {
    @ViewBuilder
    func sealTimelineGate(now: Date) -> some View {
        if reduceMotion || confirming {
            sealBody(now: now)
        } else {
            TimelineView(.periodic(from: Date(), by: 60)) { context in
                sealBody(now: context.date)
            }
        }
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        sealTimelineGate(now: Date())
            .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
            .accessibilityValue(
                ConversationStaleReadJudgment.face(
                    capturedAt: capturedAt,
                    confirming: confirming
                ).productWord
            )
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}

