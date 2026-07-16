import SwiftUI
import Observation
import AtlasCore

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

struct AtlasCodeWhySheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: AtlasCodeWhyModel
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
            }
        }
        .task { if model.phase == .idle { await model.load(repo: repo, file: file) } }
        .accessibilityIdentifier(A11yID.whySheet)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("POR QUE ESTE ARQUIVO EXISTE")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
            Text(file)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(2)
                .truncationMode(.middle)
            if let why = model.why, why.truncated {
                Text("mostrando \(why.commits.count) de \(why.commitsTotal) · história truncada")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                Text("lendo a história do arquivo…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(.top, 8)
        case .failed:
            VStack(alignment: .leading, spacing: 6) {
                Text("biografia indisponível")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                Text(model.message ?? "não consegui carregar este arquivo")
                    .font(AtlasFont.mono(9.5))
                    .foregroundStyle(AtlasCodePalette.alert)
            }
        case .loaded:
            if let why = model.why, why.commits.isEmpty {
                Text("este arquivo não tem história neste recorte")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 6)
            } else if let why = model.why {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                        whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                    }
                }
            }
        }
    }

    private func whyRow(_ commit: AtlasCodeWhy.Commit, index: Int, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(AtlasTheme.accent)
                    .frame(width: 7, height: 7)
                if !isLast {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.35))
                        .frame(width: 1)
                        .frame(minHeight: 56)
                        .accessibilityHidden(true)
                }
            }
            .padding(.top, 7)

            VStack(alignment: .leading, spacing: 5) {
                if let quote = commit.provenance?.quote {
                    Text("\u{201C}\(quote)\u{201D}")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                } else {
                    Text("sem proveniência registrada")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Text(meta(for: commit))
                    .font(AtlasFont.mono(10.5))
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text(commit.subject)
                    .font(.system(size: 11))
                    .foregroundStyle(AtlasTheme.textSecondary.opacity(0.75))
                    .lineLimit(2)
            }
            .padding(.bottom, isLast ? 0 : 18)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText(for: commit))
        .accessibilityIdentifier(A11yID.whyRow(index))
    }

    private func meta(for commit: AtlasCodeWhy.Commit) -> String {
        var parts = [commit.agentLabel]
        if let when = commit.when {
            parts.append("há \(AtlasCodeRelativeTime.short(from: Int(when.timeIntervalSince1970)))")
        }
        parts.append(commit.shortHash)
        return parts.joined(separator: " · ")
    }

    private func accessibilityText(for commit: AtlasCodeWhy.Commit) -> String {
        let quote = commit.provenance?.quote ?? "sem proveniência registrada"
        return "\(quote), \(meta(for: commit))"
    }
}
