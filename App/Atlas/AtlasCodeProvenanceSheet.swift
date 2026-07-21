import AtlasCore
import Foundation
import SwiftUI
import Observation

// Cycle 044 fuse → AtlasCodeProvenanceSheet.swift

// MARK: - Folha: por que esta linha existe (C23)

/// Alvo do sheet “por quê” a partir de um path de arquivo da proveniência.
struct AtlasCodeProvenanceWhyTarget: Identifiable {
    let path: String
    var id: String { path }
}

/// A folha responde, em ordem, as perguntas de quem abre um commit: em que
/// estado ele está, o que ele diz, por que existe, e o que ele tocou.
/// O hash fecha a folha — máquina embaixo do vidro (lei 6).
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

extension AtlasCodeProvenanceSheet {
    func hasLoadedBody(_ provenance: AtlasCodeProvenance) -> Bool {
        provenance.commitBody?.nonEmpty != nil
            || provenance.operatorQuote?.nonEmpty != nil
            || !(provenance.gates?.isEmpty ?? true)
            || !(provenance.obra?.isEmpty ?? true)
            || !provenance.files.isEmpty
    }
}

extension AtlasCodeProvenanceSheet {
    func provenanceLoadedPhaseID(_ provenance: AtlasCodeProvenance) -> String {
        hasLoadedBody(provenance) ? "loaded-\(provenance.files.count)" : "loaded-empty"
    }
}

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

extension AtlasCodeProvenanceSheet {
    func spokenStateKickerHealthy() -> String? {
        switch state {
        case .onMain: return "na \(trunk?.nonEmpty ?? "main")"
        case .healed: return "curado"
        default: return nil
        }
    }
}

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

extension AtlasCodeProvenanceSheet {
    func spokenHeaderTitle() -> String {
        node.message?.nonEmpty ?? String(node.hash.prefix(8))
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
            // Contain without fused label: ask / why file rows stay focusable.
            .accessibilityElement(children: .contain)
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

extension AtlasCodeProvenanceSheet {
    func provenanceSheetLoadedParts(_ provenance: AtlasCodeProvenance) -> [String] {
        if let headline = provenance.diffHeadline { return [headline] }
        if !hasLoadedBody(provenance) { return ["ledger sem detalhe neste recorte"] }
        return []
    }
}

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

extension AtlasCodeProvenanceSheet {
    var provenanceSheetSpokenLabel: String {
        var parts = ["proveniência do commit", spokenHeaderTitle(), spokenStateKicker()]
        parts.append(contentsOf: provenanceSheetPhaseParts())
        return parts.joined(separator: ", ")
    }
}


@MainActor
@Observable
final class AtlasCodeProvenanceModel {
    enum Phase: Equatable {
        case idle, loading, loaded(AtlasCodeProvenance), failed(String)
    }

    let client: AtlasClient
    private(set) var repo: String
    private(set) var phase: Phase = .idle
    /// O commit que a folha ABERTA pediu. Resposta de pedido velho não grava.
    private var wanted: String?

    init(client: AtlasClient, repo: String) {
        self.client = client
        self.repo = repo
    }

    func adoptRepo(_ newRepo: String) {
        guard newRepo != repo else { return }
        repo = newRepo
        phase = .idle
        wanted = nil
    }

    func load(hash: String) async {
        // A corrida real: o operador toca no commit A, fecha, toca no B — e a
        // resposta de A chega DEPOIS da de B. Sem correlacionar, a folha do B
        // mostrava a proveniência do A: autor, arquivos e "sua frase" do commit
        // errado, na tela em que o operador decide se apaga trabalho. Só a
        // resposta do pedido mais recente pode escrever o estado.
        wanted = hash
        phase = .loading
        do {
            let provenance = try await client.getCodeProvenance(hash: hash, repo: repo)
            guard wanted == hash else { return }
            phase = .loaded(provenance)
        } catch {
            guard wanted == hash else { return }
            phase = .failed(String(describing: error))
        }
    }
}
