import SwiftUI
import AtlasCore

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
}
