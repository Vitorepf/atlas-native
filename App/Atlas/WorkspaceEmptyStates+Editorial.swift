import AtlasCore
import SwiftUI

// Cycle 041 fuse → WorkspaceEmptyStates+Editorial.swift

extension WorkspaceEditorialEmpty {
    var editorialFootnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }
}

extension WorkspaceEditorialEmpty {
    var editorialHeadline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }
}

extension WorkspaceEditorialEmpty {
    var headline: String { editorialHeadline }
    var footnote: String { editorialFootnote }
}

/// ✦ + headline editorial compartilhado — workspace vazio e search miss.
struct AtlasEditorialGlyphEmpty: View {
    let headline: String
    var footnote: String? = nil
    let accessibilityIdentifier: String
    var spokenLabel: String? = nil

    var body: some View {
        editorialStack
            .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel ?? headline)
            .accessibilityIdentifier(accessibilityIdentifier)
    }
}

extension WorkspaceEditorialEmpty {
    var spokenLabel: String {
        let lead: String
        if area != .tudo {
            lead = "nada em \(area.label) em \(screenTitle)"
        } else if freeOnly {
            lead = "nenhuma conversa sem projeto ainda"
        } else {
            lead = "nenhuma conversa em \(screenTitle) ainda"
        }
        return "\(lead). \(footnote)"
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialCopyStack: some View {
        VStack(spacing: 8) {
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if let footnote {
                Text(footnote)
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialGlyph: some View {
        Text("✦")
            .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            .accessibilityHidden(true)
    }
}

extension AtlasEditorialGlyphEmpty {
    var editorialStack: some View {
        VStack(spacing: 14) {
            editorialGlyph
            editorialCopyStack
        }
    }
}

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    var body: some View {
        editorialGlyph
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    func retryButtonWithIdentifier<Content: View>(_ button: Content) -> some View {
        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}

extension AtlasNetworkFailureEmpty {
    @ViewBuilder
    var retryButton: some View {
        retryButtonWithIdentifier(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                retryLabel
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint(retryHint)
        )
    }
}
