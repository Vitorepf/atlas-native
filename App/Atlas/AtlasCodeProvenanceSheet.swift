import SwiftUI
import AtlasCore

// MARK: - Folha: por que esta linha existe (C23)

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
/// Chrome → AtlasCodeProvenanceSheet+Chrome.swift
/// Scroll → AtlasCodeProvenanceSheet+Scroll.swift
struct AtlasCodeProvenanceSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var whyTarget: AtlasCodeProvenanceWhyTarget?
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
        provenanceSheetChrome(
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                provenanceScrollStack
            }
        )
    }
}
