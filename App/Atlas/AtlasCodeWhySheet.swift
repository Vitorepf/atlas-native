import AtlasCore
import Foundation
import SwiftUI

// Cycle 043 fuse → AtlasCodeWhySheet.swift

struct AtlasCodeWhySheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWhyModel
    let repo: String
    let file: String

    init(client: AtlasClient, repo: String, file: String) {
        _model = State(initialValue: AtlasCodeWhyModel(client: client))
        self.repo = repo
        self.file = file
    }

    var body: some View {
        whyLifecycleA11y(whyBodyShell)
    }
}

extension AtlasCodeWhySheet {
    var whyContentLoadedID: String {
        guard let why = model.why else { return "loaded-nil" }
        return why.commits.isEmpty ? "empty" : "timeline-\(why.commits.count)"
    }
}

extension AtlasCodeWhySheet {
    var whyContentPhaseID: String {
        switch model.phase {
        case .idle, .loading: return "loading"
        case .failed: return "failed"
        case .loaded: return whyContentLoadedID
        }
    }
}

extension AtlasCodeWhySheet {
    func spokenCommit(_ commit: AtlasCodeWhy.Commit) -> String {
        var parts: [String] = []
        if let quote = commit.provenance?.quote, !quote.isEmpty {
            parts.append(quote)
        } else {
            parts.append("sem proveniência registrada")
        }
        parts.append(commit.agentLabel)
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        if !commit.subject.isEmpty { parts.append(commit.subject) }
        return parts.joined(separator: ", ")
    }

    static let sheetHint = "histórico de commits e proveniência registrada pelo Atlas"
}

extension AtlasCodeWhySheet {
    func spokenLoading() -> String { "lendo a história do arquivo" }

    func spokenFailed() -> String {
        if let message = model.message, !message.isEmpty {
            return "biografia indisponível, \(message)"
        }
        return "biografia indisponível"
    }

    func spokenEmptyHistory() -> String { "este arquivo não tem história neste recorte" }
}

extension AtlasCodeWhySheet {
    var whyBodyShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            whyScrollBody
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder var whyBusyContent: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyLoadingOrFailed
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyBusyContent
        case .loaded:
            if let why = model.why {
                whyLoadedCommits(why)
            }
        }
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyLoadedCommits(_ why: AtlasCodeWhy) -> some View {
        if why.commits.isEmpty {
            Text("este arquivo não tem história neste recorte")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 6)
                .accessibilityLabel(spokenEmptyHistory())
                .accessibilityAddTraits(.isHeader)
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                    whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                }
            }
        }
    }
}

extension AtlasCodeWhySheet {
    var whyFailed: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("biografia indisponível")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let message = model.message, !message.isEmpty {
                Text(message)
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasCodePalette.alert)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenFailed())
        .accessibilityAddTraits(.isHeader)
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    var headerTruncation: some View {
        if let why = model.why, why.truncated {
            Text("mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyLifecycleA11y<V: View>(_ content: V) -> some View {
        content
            .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
            .accessibilityIdentifier(A11yID.whySheet)
            .accessibilityLabel(whySheetSpokenLabel)
            .accessibilityHint(Self.sheetHint)
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    var whyLoadingOrFailed: some View {
        switch model.phase {
        case .idle, .loading:
            whyLoading
        case .failed:
            whyFailed
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeWhySheet {
    var whyLoading: some View {
        HStack(spacing: 10) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text("lendo a história do arquivo…")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenLoading())
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowConnector(isLast: Bool) -> some View {
        if !isLast {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.35))
                .frame(width: 1)
                .frame(minHeight: 56)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyRowRail(isLast: Bool) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(AtlasTheme.accent)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            whyRowConnector(isLast: isLast)
        }
        .padding(.top, 7)
        .accessibilityHidden(true)
    }
}

extension AtlasCodeWhySheet {
    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }
}

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowQuote(_ commit: AtlasCodeWhy.Commit) -> some View {
        if let quote = commit.provenance?.quote {
            Text("\u{201C}\(quote)\u{201D}")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
        } else {
            Text("sem proveniência registrada")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    func whyRowText(_ commit: AtlasCodeWhy.Commit, isLast: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            whyRowQuote(commit)
            Text(meta(for: commit))
                .font(AtlasFont.mono(10.5))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(commit.subject)
                .atlasSans(11)
                .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                .lineLimit(2)
                .accessibilityHidden(true)
        }
        .padding(.bottom, isLast ? 0 : 18)
    }
}

extension AtlasCodeWhySheet {
    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            whyRowRail(isLast: isLast)
            whyRowText(commit, isLast: isLast)
        }
        .frame(minHeight: 56, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))    }
}

extension AtlasCodeWhySheet {
    var whyScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: whyContentPhaseID)
        }
    }
}

extension AtlasCodeWhySheet {
    var whyHeaderSpokenLabel: String {
        guard let why = model.why, why.truncated else { return file }
        return "\(file), mostrando \(why.commits.count) de \(why.commitsTotal)"
    }
}

extension AtlasCodeWhySheet {
    func whySheetHistoryParts() -> [String] {
        guard model.phase == .loaded, let why = model.why else { return [] }
        if why.commits.isEmpty {
            return ["sem história neste recorte"]
        }
        var history = "\(why.commits.count) commit\(why.commits.count == 1 ? "" : "s")"
        if why.truncated { history += " de \(why.commitsTotal), história truncada" }
        return [history]
    }
}

extension AtlasCodeWhySheet {
    var whySheetSpokenLabel: String {
        var parts = ["biografia do arquivo, \(file)"]
        parts.append(contentsOf: whySheetHistoryParts())
        return parts.joined(separator: ", ")
    }
}

extension AtlasCodeWhySheet {
    var whyHeaderTitleBlock: some View {
        Group {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .atlasSans(9, .semibold)
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension AtlasCodeWhySheet {
    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            whyHeaderTitleBlock
            headerTruncation
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }
}
