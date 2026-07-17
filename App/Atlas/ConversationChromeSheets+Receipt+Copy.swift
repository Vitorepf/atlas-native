import SwiftUI
import AtlasCore

// Copy + a11y — peel de ConversationHandoffReceipt.

extension ConversationHandoffReceipt {
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
        if isReady {
            var parts = ["\(route)", "mesma thread \(thread)", "sem prompt duplicado"]
            if let age { parts.append("há \(age)") }
            return parts.joined(separator: " · ")
        }
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
