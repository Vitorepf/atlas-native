import SwiftUI
import AtlasCore

// Cycle 021 fuse → ConversationChromeSheets.swift

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
        .accessibilityAddTraits(.isStaticText)
    }
}

enum ConversationOutlineA11y {
    static func spokenSheetLabel(turnCount: Int) -> String {
        guard turnCount > 0 else { return spokenEmptySheet() }
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "índice da conversa, \(turnCount) \(noun)"
    }

    static func spokenEmptySheet() -> String {
        "índice da conversa, sem turnos carregados nesta thread"
    }
}

extension ConversationOutlineSheet {
    func outlineA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.conversationOutlineSheet)
            .accessibilityLabel(ConversationOutlineA11y.spokenSheetLabel(turnCount: bubbles.count))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: bubbles.map(\.id))
    }
}

extension ConversationOutlineA11y {
    static func spokenSnippet(from text: String) -> String {
        ConversationOutlineA11ySnippet.spokenSnippet(from: text)
    }
}

extension ConversationOutlineA11y {
    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }
}

extension ConversationOutlineA11y {
    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        ConversationOutlineA11ySnippet.spokenRow(index: index, role: role, snippet: snippet)
    }
}

enum ConversationOutlineA11ySnippet {
    static func spokenSnippet(from text: String) -> String {
        let trimmed = AtlasMarkdown.plainText(text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return "sem texto visível neste turno"
        }
        return String(trimmed.prefix(140))
    }

    static func spokenRow(index: Int, role: String, snippet: String) -> String {
        "turno \(index), \(ConversationOutlineA11y.spokenRole(role)), \(snippet)"
    }
}

extension ConversationOutlineSheet {
    @ViewBuilder
    var outlineRowList: some View {
        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
            ConversationOutlineRow(index: index + 1, bubble: bubble, reduceMotion: reduceMotion)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 6)))
        }
    }
}

// MARK: - Índice da conversa

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
}

extension ConversationOutlineSheet {
    var outlineEmpty: some View {
        Text("Nenhum turno carregado nesta thread.")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .accessibilityLabel(ConversationOutlineA11y.spokenEmptySheet())
            .accessibilityAddTraits(.isStaticText)
    }
}

extension ConversationOutlineRow {
    var snippet: String {
        ConversationOutlineA11y.spokenSnippet(from: bubble.text)
    }

    var outlineLead: some View {
        outlineLeadMeta
    }
}

extension ConversationOutlineRow {
    var outlineLeadIndex: some View {
        Text(String(format: "%02d", index))
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.accent)
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityHidden(true)
    }
}

extension ConversationOutlineRow {
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
}

extension ConversationOutlineRow {
    var outlineLeadMeta: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            outlineLeadIndex
            outlineLeadSnippetStack
            Spacer(minLength: 0)
        }
    }
}

extension ConversationOutlineRow {
    var outlineLeadRole: some View {
        Text(bubble.role == "user" ? "Você" : "Atlas")
            .font(.system(.caption, weight: .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
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
                ConversationOutlineA11y.spokenRow(index: index, role: bubble.role, snippet: snippet)
            )
    }
}

extension ConversationHandoffReceipt {
    var accessibilitySummary: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment.map { ", há \($0)" } ?? ""
        if isReady {
            return "continuidade pronta no \(dest), mesma thread \(thread), sem prompt duplicado\(age)"
        }
        if isPending {
            return "continuidade enviando para o \(dest), mesma thread \(thread)\(age)"
        }
        return "recibo de continuidade para \(dest), \(atlasHandoffStatusEditorial(handoff.status)), thread \(thread)\(age)"
    }
}

extension ConversationHandoffReceipt {
    var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }
}

extension ConversationHandoffReceipt {
    var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }
}

extension ConversationHandoffReceipt {
    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(headline)
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subline)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .atlasSans(12, .semibold)
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }
}

// iOS 17 compat: `.symbolEffect(.rotate,…)` exige iOS 18. Rotação contínua
// própria (deploymentTarget = iOS 17), respeitando Reduce Motion via `active`.
private struct ReceiptSpinEffect: ViewModifier {
    let active: Bool
    @State private var spinning = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(active && spinning ? 360 : 0))
            .animation(active ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                       value: spinning)
            .onAppear { if active { spinning = true } }
            .onChange(of: active) { _, now in spinning = now }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowHBox: some View {
        HStack(spacing: 9) {
            receiptRowLeading
            Spacer(minLength: 0)
        }
    }
}

extension ConversationHandoffReceipt {
    var receiptRowLayout: some View {
        receiptRowHBox
    }
}

extension ConversationHandoffReceipt {
    @ViewBuilder
    var receiptRowLeading: some View {
        receiptIcon
        receiptCopy
    }
}

extension ConversationHandoffReceipt {
    var receiptRowStack: some View {
        receiptRowLayout
    }
}

extension ConversationHandoffReceipt {
    func pendingSubline(route: String, thread: String, age: String?) -> String {
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    func readySubline(route: String, thread: String, age: String?) -> String {
        var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }
}

extension ConversationHandoffReceipt {
    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady { return readySubline(route: route, thread: thread, age: age) }
        return pendingSubline(route: route, thread: thread, age: age)
    }
}

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        receiptChrome(receiptRowStack)
    }
}

extension ConversationHandoffReceipt {
    func receiptChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.goldVeil))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 2)
            .padding(.bottom, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilitySummary)
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
    }
}

extension StaleReadSeal {
    @ViewBuilder
    func sealBody(now: Date) -> some View {
        sealChrome(now: now)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(StaleReadSealA11y.spokenLabel(
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
            Text(StaleReadSealA11y.displayCaption(
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

enum StaleReadSealA11y {
    static func spokenLabel(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion
                ? "histórico salvo atualizado"
                : "histórico salvo atualizado após sincronizar"
        }
        return "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
    }
}

extension StaleReadSealA11y {
    static func displayCaption(
        capturedAt: Date,
        now: Date,
        confirming: Bool,
        reduceMotion: Bool
    ) -> String {
        if confirming {
            return reduceMotion ? "leitura atualizada" : "leitura sincronizada"
        }
        return "visto há \(atlasRelativeAgePT(since: capturedAt, now: now))"
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
            .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }
}

// Receipt/seals: ConversationChromeSheets+Receipt.swift
