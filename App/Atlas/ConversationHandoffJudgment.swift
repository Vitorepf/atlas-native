import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Handoff Judgment + Receipt fused

// MARK: - Judgment

// MARK: - Types

/// Exclusive conversation surface-handoff face (WAVE-045).
enum ConversationHandoffFace: Equatable {
    case absent
    case pending
    case ready
    case other(String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .pending: return "pending"
        case .ready: return "ready"
        case .other: return "other"
        }
    }

    var spokenStatus: String {
        switch self {
        case .absent: return "sem handoff"
        case .pending: return "enviando"
        case .ready: return "pronto"
        case .other(let raw): return atlasHandoffStatusEditorial(raw)
        }
    }
}

// MARK: - Judgment

/// Pure continuity handoff grammar — face · copy · pack · spoken.
enum ConversationHandoffJudgment {

    static func face(from handoff: AtlasAiSurfaceHandoff?) -> ConversationHandoffFace {
        guard let handoff else { return .absent }
        switch handoff.status {
        case "ready": return .ready
        case "pending": return .pending
        default: return .other(handoff.status)
        }
    }

    static func isReady(_ handoff: AtlasAiSurfaceHandoff) -> Bool {
        face(from: handoff) == .ready
    }

    static func isPending(_ handoff: AtlasAiSurfaceHandoff) -> Bool {
        face(from: handoff) == .pending
    }

    static func destinationLabel(_ handoff: AtlasAiSurfaceHandoff) -> String {
        atlasSurfaceLabel(handoff.toSurface)
    }

    static func routeLine(_ handoff: AtlasAiSurfaceHandoff) -> String {
        "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
    }

    static func threadPrefix(_ handoff: AtlasAiSurfaceHandoff) -> String {
        editorialThreadPrefix(handoff.threadId)
    }

    static func ageFragment(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date, now: now)
    }

    static func headline(_ handoff: AtlasAiSurfaceHandoff) -> String {
        let dest = destinationLabel(handoff)
        switch face(from: handoff) {
        case .ready: return "Pronto no \(dest)"
        case .pending: return "Enviando para o \(dest)…"
        case .other: return "Continuidade para \(dest)"
        case .absent: return "Continuidade"
        }
    }

    static func subline(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String {
        let route = routeLine(handoff)
        let thread = threadPrefix(handoff)
        let age = ageFragment(handoff, now: now)
        switch face(from: handoff) {
        case .ready:
            var parts = [route, "mesma thread \(thread)", "sem prompt duplicado"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        case .pending, .other, .absent:
            var parts = [face(from: handoff).spokenStatus, route, "thread \(thread)"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        }
    }

    static func spoken(_ handoff: AtlasAiSurfaceHandoff, now: Date = Date()) -> String {
        let dest = destinationLabel(handoff)
        let thread = threadPrefix(handoff)
        let age = ageFragment(handoff, now: now).map { ", há \($0)" } ?? ""
        switch face(from: handoff) {
        case .ready:
            return "continuidade pronta no \(dest), mesma thread \(thread), sem prompt duplicado\(age)"
        case .pending:
            return "continuidade enviando para o \(dest), mesma thread \(thread)\(age)"
        case .other, .absent:
            return "recibo de continuidade para \(dest), \(face(from: handoff).spokenStatus), thread \(thread)\(age)"
        }
    }

    static func packFacts(from handoff: AtlasAiSurfaceHandoff?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: handoff)
        facts.append("handoff_face: \(face.productWord)")
        guard let handoff else {
            absences.append("nenhum handoff de superfície neste recorte")
            return (facts, absences)
        }
        facts.append("handoff_status: \(handoff.status)")
        facts.append("route: \(routeLine(handoff))")
        facts.append("thread: \(threadPrefix(handoff))")
        facts.append("to_surface: \(handoff.toSurface)")
        facts.append("from_surface: \(handoff.fromSurface)")
        if let age = ageFragment(handoff) {
            facts.append("age: \(age)")
        } else {
            absences.append("created_at ausente no handoff")
        }
        return (facts, absences)
    }
}

// MARK: - Receipt

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // WAVE-045: face owned by Judgment.
    var face: ConversationHandoffFace { ConversationHandoffJudgment.face(from: handoff) }
    var isReady: Bool { ConversationHandoffJudgment.isReady(handoff) }
    var isPending: Bool { ConversationHandoffJudgment.isPending(handoff) }

    var body: some View {
        receiptChrome(receiptRowStack)
    }

    // MARK: - Layout

    var receiptRowStack: some View {
        HStack(spacing: 9) {
            receiptIcon
            receiptCopy
            Spacer(minLength: 0)
        }
    }

    var receiptIcon: some View {
        Image(systemName: isReady ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
            .atlasSans(12, .semibold)
            .foregroundStyle(isReady ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ReceiptSpinEffect(active: isPending && !reduceMotion))
            .accessibilityHidden(true)
    }

    var receiptCopy: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(ConversationHandoffJudgment.headline(handoff))
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(ConversationHandoffJudgment.subline(handoff))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }

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
            .accessibilityLabel(ConversationHandoffJudgment.spoken(handoff))
            .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
            .accessibilityValue(face.productWord)
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
