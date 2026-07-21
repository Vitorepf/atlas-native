import AtlasCore
import SwiftUI

// Cycle 041 fuse → WorkspaceView.swift

// Dentro de um workspace (repo): as conversas dele, com filtro de área no topo
// (Tudo / Operacional / Autônomos / Programação). Título em Fraunces serif.
// Vazio ≠ offline: falha de rede usa a mesma voz da home (`AtlasFailureCopy`).
// Chrome: +Chrome · lista: +Scroll · spoken: +A11y · empty: WorkspaceEmptyStates
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
        workspaceScreenChrome(workspaceBodyStack)
    }
}
