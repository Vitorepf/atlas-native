import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: WhySheet + WhyModel fused

// MARK: - Sheet

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
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
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
        .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
        .accessibilityIdentifier(A11yID.whySheet)
        .accessibilityLabel(whySheetSpokenLabel)
        .accessibilityHint(Self.sheetHint)
    }

    // MARK: - Header

    var header: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            // WAVE-056: truncation banner from Judgment (published counts only).
            if let why = model.why, let banner = AtlasCodeWhyJudgment.truncatedBanner(why) {
                Text(banner)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(whyHeaderSpokenLabel)
    }

    // MARK: - Content

    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading:
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
        case .failed:
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
        case .loaded:
            if let why = model.why {
                if why.commits.isEmpty {
                    Text("este arquivo não tem história neste recorte")
                        .font(AtlasFont.serifItalic(16))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 6)
                        .accessibilityLabel(spokenEmptyHistory())
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                            whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Rows

    func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AtlasTheme.accent)
                    .frame(width: 7, height: 7)
                    .accessibilityHidden(true)
                if !isLast {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.35))
                        .frame(width: 1)
                        .frame(minHeight: 56)
                        .accessibilityHidden(true)
                }
            }
            .padding(.top, 7)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 5) {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenCommit(commit))
        .accessibilityIdentifier(A11yID.whyRow(index))
    }

    func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        if let obra = commit.provenance?.obra, !obra.isEmpty { parts.append(obra) }
        return parts.joined(separator: " · ")
    }

    // MARK: - A11y (WAVE-056: Judgment face)

    var whyFace: AtlasCodeWhyFace {
        AtlasCodeWhyJudgment.face(model: model)
    }

    var whyContentPhaseID: String {
        AtlasCodeWhyJudgment.contentPhaseID(face: whyFace)
    }

    var whyHeaderSpokenLabel: String {
        AtlasCodeWhyJudgment.spokenHeader(file: file, face: whyFace)
    }

    var whySheetSpokenLabel: String {
        AtlasCodeWhyJudgment.spokenSheet(file: file, face: whyFace)
    }

    func spokenLoading() -> String {
        AtlasCodeWhyFace.loading.spokenFace
    }

    func spokenFailed() -> String {
        AtlasCodeWhyJudgment.face(
            phase: .failed(""),
            why: nil,
            message: model.message
        ).spokenFace
    }

    func spokenEmptyHistory() -> String {
        AtlasCodeWhyFace.empty.spokenFace
    }

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

// MARK: - Model

@MainActor
@Observable
final class AtlasCodeWhyModel {
    private let client: AtlasClient
    private(set) var phase: LoadPhase = .idle
    private(set) var why: AtlasCodeWhy?
    private(set) var message: String?
    private var wanted: String?

    init(client: AtlasClient) {
        self.client = client
    }

    func load(repo: String, file: String) async {
        let key = "\(repo)\n\(file)"
        wanted = key
        phase = .loading
        message = nil
        do {
            let response = try await client.getCodeWhy(repo: repo, file: file)
            guard wanted == key else { return }
            why = response
            phase = .loaded
        } catch {
            guard wanted == key else { return }
            message = String(describing: error)
            phase = .failed(message ?? "falha desconhecida")
        }
    }
}

// MARK: - Judgment

// MARK: - Types

/// Exclusive file-biography (H1 Why) face (WAVE-056).
enum AtlasCodeWhyFace: Equatable {
    case loading
    case failed(String?)
    case empty
    case timeline(Int)
    case truncated(shown: Int, total: Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline: return "timeline"
        case .truncated: return "truncated"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading:
            return "lendo a história do arquivo"
        case .failed(let message):
            if let message, !message.isEmpty {
                return "biografia indisponível, \(message)"
            }
            return "biografia indisponível"
        case .empty:
            return "este arquivo não tem história neste recorte"
        case .timeline(let n):
            return n == 1
                ? "1 commit na biografia do arquivo"
                : "\(n) commits na biografia do arquivo"
        case .truncated(let shown, let total):
            return "mostrando \(shown) de \(total) commits, história truncada"
        }
    }
}

// MARK: - Judgment

/// Pure Why biography grammar — face · spoken · pack.
enum AtlasCodeWhyJudgment {

    static func face(
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> AtlasCodeWhyFace {
        switch phase {
        case .idle, .loading:
            return .loading
        case .failed:
            return .failed(message)
        case .loaded:
            guard let why else { return .empty }
            if why.commits.isEmpty { return .empty }
            if why.truncated {
                return .truncated(shown: why.commits.count, total: why.commitsTotal)
            }
            return .timeline(why.commits.count)
        }
    }

    /// Convenience when model is available on MainActor.
    @MainActor
    static func face(model: AtlasCodeWhyModel) -> AtlasCodeWhyFace {
        face(phase: model.phase, why: model.why, message: model.message)
    }

    static func truncatedBanner(_ why: AtlasCodeWhy) -> String? {
        guard why.truncated else { return nil }
        return "mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada"
    }

    static func spokenSheet(file: String, face: AtlasCodeWhyFace) -> String {
        "biografia do arquivo \(file), \(face.spokenFace)"
    }

    static func spokenHeader(file: String, face: AtlasCodeWhyFace) -> String {
        switch face {
        case .truncated(let shown, let total):
            return "\(file), mostrando \(shown) de \(total)"
        default:
            return file
        }
    }

    static func contentPhaseID(face: AtlasCodeWhyFace) -> String {
        switch face {
        case .loading: return "loading"
        case .failed: return "failed"
        case .empty: return "empty"
        case .timeline(let n): return "timeline-\(n)"
        case .truncated(let shown, let total): return "truncated-\(shown)-\(total)"
        }
    }

    static func packFacts(
        file: String,
        phase: LoadPhase,
        why: AtlasCodeWhy?,
        message: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(phase: phase, why: why, message: message)
        facts.append("why_face: \(face.productWord)")
        facts.append("why_file: \(file)")
        switch face {
        case .loading:
            absences.append("biografia ainda carregando")
        case .failed(let msg):
            absences.append("biografia falhou")
            if let msg, !msg.isEmpty { facts.append("why_error: \(msg)") }
        case .empty:
            absences.append("sem commits na biografia deste recorte")
        case .timeline(let n):
            facts.append("why_commits: \(n)")
        case .truncated(let shown, let total):
            facts.append("why_commits_shown: \(shown)")
            facts.append("why_commits_total: \(total)")
            facts.append("why_truncated: true")
        }
        return (facts, absences)
    }
}
