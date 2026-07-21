import AtlasCore
import SwiftUI

/// M5 · Espelho — o que sairia do Mac, e o que a varredura encontrou.
/// WAVE-009: single instrument (quiet healthy / blocked / pending) — zero peel fog.
struct AtlasCodeMirrorCard: View {
    let response: AtlasCodeMirrorResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Espelho")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer()
                if let host = response.mirror?.host {
                    Text(host)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            headline
            blockedRulesRow
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).strokeBorder(borderColor, lineWidth: 1))
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.35), value: mirrorStatePhaseID)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMirrorLabel())
        .accessibilityHint(Self.mirrorHint)
        .accessibilityIdentifier(A11yID.codeMirror)
    }

    // MARK: - Headline (silence-when-healthy = quiet tone, no decorative check spam)

    @ViewBuilder
    var headline: some View {
        switch response.state {
        case .blocked:
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        case .mirrored:
            label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
        case .pending(let commits):
            label(
                commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
                color: AtlasTheme.textSecondary,
                icon: "internaldrive"
            )
        case .noMirror:
            label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
        case .unknown:
            label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
        }
    }

    @ViewBuilder
    var blockedRulesRow: some View {
        if case .blocked(let rules) = response.state {
            HStack(spacing: 5) {
                ForEach(rules, id: \.self) { rule in
                    Text(rule)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .overlay(Capsule().strokeBorder(AtlasCodePalette.alert.opacity(0.3), lineWidth: 1))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }

    func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text(text)
                .atlasSans(12.5)
                .accessibilityHidden(true)
        }
        .foregroundStyle(color)
        .accessibilityHidden(true)
    }

    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }

    // MARK: - A11y

    var mirrorStatePhaseID: String {
        switch response.state {
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        }
    }

    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        parts.append(contentsOf: spokenMirrorStateParts())
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    func spokenMirrorStateParts() -> [String] {
        switch response.state {
        case .mirrored:
            return ["tudo espelhado, verdade no Mac"]
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        case .pending(let commits):
            return ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
        case .blocked(let rules):
            var parts = ["bloqueado, segredo detectado"]
            if !rules.isEmpty {
                parts.append("regras \(rules.joined(separator: ", "))")
            }
            return parts
        }
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}
