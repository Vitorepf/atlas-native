import SwiftUI
import UIKit
import AtlasCore

struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedID: String?
    @State private var preview: PreviewState = .idle

    private var artifacts: AtlasTraceArtifacts? { reviews.artifactsByTrace[traceId] }
    private var items: [AtlasTraceArtifacts.Item] {
        guard artifacts?.state == .available else { return [] }
        return artifacts?.items ?? []
    }
    private var selected: AtlasTraceArtifacts.Item? {
        items.first { $0.id == selectedID } ?? items.first
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                content
            }
            .navigationTitle("Artefatos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Fechar") { dismiss() } }
            }
            .overlay(alignment: .top) { toast }
            .accessibilityIdentifier(A11yID.artifactsSheet)
        }
        .task { await reviews.refreshArtifacts(traceId: traceId) }
        .onChange(of: items.map(\.id)) { _, ids in
            if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
                selectedID = ids.first
            }
        }
        .task(id: selected?.id) {
            guard let selected else { return }
            await load(selected)
        }
    }

    @ViewBuilder
    private var content: some View {
        if artifacts == nil {
            loading("consultando artefatos…")
        } else if items.isEmpty {
            VStack(spacing: 12) {
                BreathingDiamond(size: 10, reduceMotion: true)
                Text("Sem artefatos visualizáveis nesta execução.")
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(36)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
                    .font(AtlasFont.mono(10)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 14)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        artifactList
                        previewPane
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    selectedID = item.id
                } label: {
                    HStack(spacing: 10) {
                        Text("▸")
                            .font(AtlasFont.mono(11))
                            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
                        Text(item.name)
                            .font(AtlasFont.serif(15, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("\(byteLabel(item.byteSize))  \(kindLabel(item.kind))")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.artifactsItem(index))
                .accessibilityLabel("\(item.name), \(byteLabel(item.byteSize)), \(kindLabel(item.kind))")
                if index < items.count - 1 { Divider().overlay(AtlasTheme.separatorSoft) }
            }
        }
        .padding(.horizontal, 12)
        .atlasCard()
    }

    @ViewBuilder
    private var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch preview {
            case .idle, .loading:
                loading("carregando preview…")
                    .frame(maxWidth: .infinity, minHeight: 180)
            case .tooLarge(let bytes):
                fileFicha(subtitle: "grande demais para visualizar aqui · \(byteLabel(bytes))")
            case .failed(let message):
                Text(message)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .loaded(let item, let content):
                previewContent(item: item, content: content)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
    }

    @ViewBuilder
    private func previewContent(item: AtlasTraceArtifacts.Item, content: AtlasArtifactContent) -> some View {
        switch item.kind {
        case .image:
            if let image = UIImage(data: content.data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                fileFicha(subtitle: "imagem não pôde ser decodificada · \(byteLabel(item.byteSize))")
            }
        case .markdown, .text:
            AtlasMarkdownView(text: String(decoding: content.data, as: UTF8.self), streaming: false)
        case .diff:
            ScrollView(.horizontal, showsIndicators: false) {
                Text(String(decoding: content.data, as: UTF8.self))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 360)
        case .file:
            fileFicha(subtitle: "\(byteLabel(item.byteSize)) · sha \(String(item.sha256.prefix(12)))")
        }
    }

    private func fileFicha(subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selected?.name ?? "artefato")
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(subtitle)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func loading(_ text: String) -> some View {
        VStack(spacing: 10) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func load(_ item: AtlasTraceArtifacts.Item) async {
        preview = .loading
        do {
            let content = try await reviews.loadArtifactContent(traceId: traceId, item: item)
            preview = .loaded(item, content)
        } catch let api as AtlasApiError where api.status == 413 {
            preview = .tooLarge(item.byteSize)
        } catch {
            preview = .failed(atlasUserMessage(for: error))
        }
    }

    @ViewBuilder private var toast: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation(AtlasMotion.editorial) { reviews.toast = nil }
                }
        }
    }

    private func kindLabel(_ kind: AtlasTraceArtifacts.Item.Kind) -> String {
        switch kind {
        case .image: "imagem"
        case .markdown: "markdown"
        case .text: "texto"
        case .diff: "diff"
        case .file: "arquivo"
        }
    }

    private func byteLabel(_ bytes: Int) -> String {
        if bytes < 1_024 { return "\(bytes) B" }
        if bytes < 1_048_576 { return "\(max(1, bytes / 1_024)) KB" }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
    }

    private enum PreviewState {
        case idle
        case loading
        case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
        case tooLarge(Int)
        case failed(String)
    }
}
