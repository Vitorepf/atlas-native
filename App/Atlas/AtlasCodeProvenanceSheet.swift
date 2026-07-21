import SwiftUI
import AtlasCore

// WAVE-009 fused Provenance sheet host + a11y
// Single-feature peel fusion for Code depth instrument.

extension AtlasCodeProvenanceSheet {
    /// WAVE-057: body gate + face from Judgment.
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        AtlasCodeProvenanceJudgment.hasLoadedBody(provenance)
    }

    var provenanceFace: AtlasCodeProvenanceFace {
        AtlasCodeProvenanceJudgment.face(phase: phase)
    }

    var provenanceContentPhaseID: String {
        provenanceFace.contentPhaseID
    }

    func spokenLoading() -> String {
        AtlasCodeProvenanceFace.loading.spokenFace
    }

    func spokenFailed(_ message: String) -> String {
        AtlasCodeProvenanceFace.failed(message).spokenFace
    }

    static let sheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let askHint = "abre conversa com este commit no assunto"

    func spokenStateKicker() -> String {
        AtlasCodeProvenanceJudgment.spokenStateKicker(state: state, trunk: trunk)
    }

    func spokenHeaderTitle() -> String {
        AtlasCodeProvenanceJudgment.headerTitle(node: node)
    }

    var provenanceSheetSpokenLabel: String {
        AtlasCodeProvenanceJudgment.spokenSheet(
            node: node,
            state: state,
            trunk: trunk,
            phase: phase
        )
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenDateline() -> String {
        let author = node.authorName.isEmpty ? node.authorEmail : node.authorName
        var parts = [author]
        if case .loaded(let provenance) = phase, !provenance.agent.isEmpty {
            parts.append(provenance.agentLabel)
        }
        parts.append("há \(AtlasCodeRelativeTime.short(from: node.authoredAt))")
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeProvenanceSheet {
    func spokenLawCitation() -> String? {
        guard state == .violating, let ruleId else { return nil }
        var parts = [AtlasCodeIssue.law(ruleId, trunk: trunk)]
        if let ruleCanon = ruleCanon?.nonEmpty { parts.append(ruleCanon) }
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceBodyShell: some View {
        provenanceSheetChrome(provenanceSurface)
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceSheetChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(provenanceSheetSpokenLabel)
            .accessibilityHint(Self.sheetHint)
            .sheet(item: $whyTarget) { target in
                AtlasCodeWhySheet(client: client, repo: repo, file: target.path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceScrollStack: some View {
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
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: provenanceContentPhaseID)
        }
    }
}

extension AtlasCodeProvenanceSheet {
    var provenanceSurface: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            provenanceScrollStack
        }
    }
}

// MARK: - Folha: por que esta linha existe (C23)

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
/// Chrome → AtlasCodeProvenanceSheet+Chrome.swift
/// Scroll → AtlasCodeProvenanceSheet+Scroll.swift
/// Surface → AtlasCodeProvenanceSheet+Surface.swift
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
        provenanceBodyShell
    }
}

