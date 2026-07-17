import SwiftUI
import AtlasCore

// MARK: - Folha: por que esta linha existe (C23)

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
struct AtlasCodeProvenanceSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var whyTarget: AtlasCodeProvenanceWhyTarget?
    let client: AtlasClient
    let repo: String
    let node: AtlasCodeGraphNode
    let state: AtlasCodeNodeState
    let ruleId: String?
    /// O doc que sustenta a acusação. Ausente = a regra ainda não tem lei
    /// escrita, e isso é dito calando — nunca com um caminho plausível.
    let ruleCanon: String?
    /// A trunk real — a lei citada fala o nome da linha, nunca "main" no chute.
    let trunk: String?
    let phase: AtlasCodeProvenanceModel.Phase
    /// A saída do beco: daqui o operador fala com o agente SOBRE este commit.
    let onAsk: () -> Void

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    lawCitation
                    askButton
                    provenanceContent(whyTarget: $whyTarget)
                    hashFooter
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
                .padding(.bottom, 12)
            }
        }
        .sheet(item: $whyTarget) { target in
            AtlasCodeWhySheet(client: client, repo: repo, file: target.path)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}
