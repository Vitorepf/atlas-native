import SwiftUI
import AtlasCore

// Índice, recibo de continuidade e selos de leitura — peel de ConversationSheets
// (régua anti-inchaço). Callbacks e A11yIDs idênticos; zero mudança de rota.

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]

    var body: some View {
        SheetShell(title: "Índice da conversa") {
            ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                ConversationOutlineRow(index: index + 1, bubble: bubble)
            }
        }
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .contentTransition(.numericText())
            VStack(alignment: .leading, spacing: 3) {
                Text(bubble.role == "user" ? "Você" : "Atlas")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(snippet)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("turno \(index), \(bubble.role == "user" ? "você" : "Atlas"), \(snippet)")
    }

    private var snippet: String {
        let text = AtlasMarkdown.plainText(bubble.text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "sem texto visível" : String(text.prefix(140))
    }
}

// MARK: - Recibo de continuidade + selos

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isReady: Bool { handoff.status == "ready" }
    private var isPending: Bool { handoff.status == "pending" }

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .symbolEffect(.rotate, isActive: isPending && !reduceMotion)
            VStack(alignment: .leading, spacing: 2) {
                Text(headline)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(subline)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }

    private var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        if isReady {
            return "\(route) · mesma thread \(thread)"
        }
        return "\(atlasHandoffStatusEditorial(handoff.status)) · \(route) · thread \(thread)"
    }

    private var accessibilitySummary: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        let thread = editorialThreadPrefix(handoff.threadId)
        if isReady {
            return "continuidade pronta no \(dest), mesma thread \(thread)"
        }
        if isPending {
            return "continuidade enviando para o \(dest), mesma thread \(thread)"
        }
        return "recibo de continuidade para \(dest), \(atlasHandoffStatusEditorial(handoff.status)), thread \(thread)"
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10, weight: .semibold))
                Text(reduceMotion && confirming
                     ? "leitura atualizada"
                     : "visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
                    .font(AtlasFont.mono(11))
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
            .accessibilityLabel(confirming
                                ? "histórico salvo atualizado"
                                : "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
        }
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
    }
}

// MARK: - Continuity copy (presentation-only; sem contrato novo)

func atlasSurfaceLabel(_ raw: String) -> String {
    switch raw {
    case "atlas_mobile": return "iPhone"
    case "atlas_desktop": return "Mac"
    case "atlas_terminal": return "Terminal"
    default: return raw
    }
}

func atlasHandoffStatusEditorial(_ status: String) -> String {
    switch status {
    case "ready": return "pronto"
    case "pending": return "enviando"
    default: return status
    }
}

func editorialThreadPrefix(_ threadId: String) -> String {
    let trimmed = threadId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard trimmed.count > 12 else { return trimmed }
    return String(trimmed.prefix(12)) + "…"
}

func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}
