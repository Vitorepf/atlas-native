import SwiftUI
import AtlasCore

// Cycle 021 fuse → ConversationChrome+ComposerSheets.swift

enum ComposerSheetA11y {}

extension ComposerSheetA11y {
    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let workspaceSheetHint = "escolhe a pasta do próximo envio entre as conversas carregadas"
}

extension ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }
}

extension ComposerSheetA11y {
    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"
}

extension ModeSheet {
    var modeFootnote: some View {
        Text(ComposerSheetA11y.modeFootnote)
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension ModeSheet {
    var modeRows: some View {
        ForEach(Self.modes, id: \.0) { key, label in
            let isSelected = key == selected
            SheetRow(
                label: label,
                sub: ComposerSheetA11y.modeFootnote,
                selected: isSelected,
                accessibilityLabel: ComposerSheetA11y.modeLabel(key, title: label, selected: isSelected),
                accessibilityIdentifier: A11yID.modeRow(key)
            ) {
                selected = key
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                dismiss()
            }
        }
    }
}

extension ModeSheet {
    static let modes = [
        ("geral", "Geral"),
        ("operacional", "Operacional"),
        ("autônomos", "Autônomos"),
        ("programação", "Programação"),
    ]
}

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                workspaceEmptyLabel
            } else {
                workspaceList
            }
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel("workspace da conversa")
        .accessibilityHint(ComposerSheetA11y.workspaceSheetHint)
    }
}

extension WorkspaceSheet {
    var workspaceEmptyLabel: some View {
        Text("Nenhum workspace nas conversas carregadas")
            .atlasSans(15)
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .accessibilityLabel(ComposerSheetA11y.workspaceEmpty)
    }
}

extension WorkspaceSheet {
    var workspaceListHeader: some View {
        Text("pastas das conversas carregadas · vale no próximo envio")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
    }

    func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
            workspaceRow(ws)
        }
    }
}

extension WorkspaceSheet {
    func workspaceRowPick(_ ws: Workspace) {
        onPick(ws)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRowBuild(_ ws: Workspace, isSelected: Bool) -> some View {
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetA11y.workspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            workspaceRowPick(ws)
        }
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        workspaceRowBuild(ws, isSelected: ws.name == current)
    }
}

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) var dismiss  // interno: peels em outros arquivos usam
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            modeFootnote
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel("modo da conversa")
        .accessibilityHint(ComposerSheetA11y.modeSheetHint)
    }
}
