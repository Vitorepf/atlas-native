import SwiftUI
import AtlasCore

// Recibo de continuidade — peel de ConversationChromeSheets; selos → +Seals.

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
        .accessibilityIdentifier(A11yID.continuityHandoffReceipt)
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
        let age = handoffAgeFragment
        if isReady {
            var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        }
        var parts = [atlasHandoffStatusEditorial(handoff.status), route, "thread \(thread)"]
        if let age { parts.append("há \(age)") }
        return parts.joined(separator: " · ")
    }

    private var handoffAgeFragment: String? {
        guard let raw = handoff.createdAt, let date = AtlasTime.date(raw) else { return nil }
        return atlasRelativeAgePT(since: date)
    }

    private var accessibilitySummary: String {
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
