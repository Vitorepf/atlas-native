import AtlasCore
import Foundation
import SwiftUI

// Cycle 039 fuse → AtlasCodeProvenanceSheet+A11yKickers.swift

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
