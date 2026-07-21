import SwiftUI
import AtlasCore

// Recibo de continuidade — fusão idle dos peels Receipt*. Selos → +Seals.

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isReady: Bool { handoff.status == "ready" }
    var isPending: Bool { handoff.status == "pending" }

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

    // MARK: - Copy

    var headline: String {
        let dest = atlasSurfaceLabel(handoff.toSurface)
        if isReady { return "Pronto no \(dest)" }
        if isPending { return "Enviando para o \(dest)…" }
        return "Continuidade para \(dest)"
    }

    var subline: String {
        let route = "\(atlasSurfaceLabel(handoff.fromSurface)) → \(atlasSurfaceLabel(handoff.toSurface))"
        let thread = editorialThreadPrefix(handoff.threadId)
        let age = handoffAgeFragment
        if isReady { return readySubline(route: route, thread: thread, age: age) }
        return pendingSubline(route: route, thread: thread, age: age)
    }

    func readySubline(route: String, thread: String, age: String?) -> String {
        var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }

    func pendingSubline(route: String, thread: String, age: String?) -> String {
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }

    var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }

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
