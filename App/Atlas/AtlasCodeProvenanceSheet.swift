import SwiftUI
import AtlasCore

// WAVE-009 fused Provenance sheet host + a11y
// Single-feature peel fusion for Code depth instrument.

// --- fused from AtlasCodeProvenanceSheet+A11y+LoadedBody.swift ---
extension AtlasCodeProvenanceSheet {
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11y+LoadedPhaseID.swift ---
extension AtlasCodeProvenanceSheet {
    func provenanceLoadedPhaseID(_ provenance: AtlasCodeProvenance) -> String {
        hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11y.swift ---
extension AtlasCodeProvenanceSheet {
    var provenanceContentPhaseID: String {
        switch phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded(let provenance):
            return provenanceLoadedPhaseID(provenance)
        }
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11yHints.swift ---
extension AtlasCodeProvenanceSheet {
    func spokenLoading() -> String { "lendo proveniência do commit" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "proveniência indisponível" }
        return "proveniência indisponível, \(trimmed)"
    }

    static let sheetHint = "estado do commit, lei aplicável e o que o ledger registrou"
    static let askHint = "abre conversa com este commit no assunto"
}

// --- fused from AtlasCodeProvenanceSheet+A11yKickers+State+Healthy.swift ---
extension AtlasCodeProvenanceSheet {
    func spokenStateKickerHealthy() -> String? {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        default: return nil
        }
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11yKickers+State.swift ---
extension AtlasCodeProvenanceSheet {
    func spokenStateKicker() -> String {
        if let healthy = spokenStateKickerHealthy() { return healthy }
        switch state {
        case .violating: return "fora da \(trunk?.nonEmpty ?? "main")"
        case .history: return "história"
        default: return "história"
        }
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11yKickers.swift ---
extension AtlasCodeProvenanceSheet {
    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11ySpoken+Phase+Loaded.swift ---
extension AtlasCodeProvenanceSheet {
    func provenanceSheetLoadedParts(_ provenance: AtlasCodeProvenance) -> [String] {
        if let headline = provenance.diffHeadline { return [headline] }
        if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
        return []
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11ySpoken+Phase.swift ---
extension AtlasCodeProvenanceSheet {
    func provenanceSheetPhaseParts() -> [String] {
        switch phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        case .loaded(let provenance):
            return provenanceSheetLoadedParts(provenance)
        }
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11ySpoken.swift ---
extension AtlasCodeProvenanceSheet {
    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        parts.append(contentsOf: provenanceSheetPhaseParts())
        return parts.joined(separator: ", ")
    }
}

// --- fused from AtlasCodeProvenanceSheet+A11ySpokenCopy+Dateline.swift ---
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

// --- fused from AtlasCodeProvenanceSheet+A11ySpokenCopy+Law.swift ---
extension AtlasCodeProvenanceSheet {
    func spokenLawCitation() -> String? {
        guard state == .violating, let ruleId else { return nil }
        var parts = [AtlasCodeIssue.law(ruleId, trunk: trunk)]
        if let ruleCanon = ruleCanon?.nonEmpty { parts.append(ruleCanon) }
        return parts.joined(separator: ", ")
    }
}

// --- fused from AtlasCodeProvenanceSheet+BodyShell.swift ---
extension AtlasCodeProvenanceSheet {
    var provenanceBodyShell: some View {
        provenanceSheetChrome(provenanceSurface)
    }
}

// --- fused from AtlasCodeProvenanceSheet+Chrome.swift ---
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

// --- fused from AtlasCodeProvenanceSheet+Scroll.swift ---
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

// --- fused from AtlasCodeProvenanceSheet+Surface.swift ---
extension AtlasCodeProvenanceSheet {
    var provenanceSurface: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            provenanceScrollStack
        }
    }
}

// --- fused from AtlasCodeProvenanceSheet.swift ---
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


