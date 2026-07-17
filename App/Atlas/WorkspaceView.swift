import SwiftUI
import AtlasCore

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
// Chrome: +Chrome · lista: +Scroll · spoken: +A11y · empty: WorkspaceEmptyStates
// Predicates → WorkspaceView+Predicates.swift
struct WorkspaceView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let workspaceKey: String?
    let title: String
    /// Modo sem projeto: só conversas com workspace nulo (perguntas, pesquisas,
    /// pensamento livre — o uso GPT-no-iPhone). O projeto é opcional, não regra.
    var freeOnly: Bool = false
    @State var area: AtlasArea = .tudo

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                if !showsNetworkFailure && !showsLoadingShell {
                    areaFilter
                }
                listView
            }
            if !showsNetworkFailure && !showsLoadingShell {
                newPill
            }
        }
        .navigationBarHidden(true)
        .accessibilityIdentifier(A11yID.workspaceScreen)
        .accessibilityLabel(spokenWorkspaceScreenLabel())
        .accessibilityHint(workspaceScreenHint)
    }
}
