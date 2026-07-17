import SwiftUI
import AtlasCore

// Estados editoriais — peel de WorkspaceEmptyStates.

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    private var headline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }

    private var footnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }

    private var spokenLabel: String {
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

    var body: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            Text(footnote)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
        .accessibilityIdentifier(A11yID.workspaceEmpty)
    }
}
