import SwiftUI
import UIKit
import AtlasCore

// Lista, preview e estados vazios — extraídos do shell da sheet.
extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
        if !loadFinished, artifacts == nil {
            loading("consultando artefatos…")
        } else if loadFinished, artifacts == nil {
            evidenceEmpty(
                title: "Não foi possível consultar artefatos.",
                subtitle: "feche e tente de novo — o motivo pode estar no aviso superior.",
                identifier: A11yID.artifactsLoadFailure,
                spoken: "não foi possível consultar artefatos"
            )
        } else if artifacts?.state == .unavailable {
            evidenceEmpty(
                title: "Sem artefatos nesta execução.",
                subtitle: TraceEvidenceCopy.unavailableReason(artifacts?.reason),
                identifier: A11yID.artifactsUnavailable,
                spoken: unavailableSpokenLabel
            )
        } else if items.isEmpty {
            evidenceEmpty(
                title: "Sem artefatos visualizáveis nesta execução.",
                subtitle: nil,
                identifier: A11yID.artifactsEmpty,
                spoken: "sem artefatos visualizáveis nesta execução"
            )
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

    var artifactList: some View {
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
                        Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.artifactsItem(index))
                .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
                if index < items.count - 1 { Divider().overlay(AtlasTheme.separatorSoft) }
            }
        }
        .padding(.horizontal, 12)
        .atlasCard()
    }

    @ViewBuilder
    var previewPane: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch preview {
            case .idle, .loading:
                loading("carregando preview…")
                    .frame(maxWidth: .infinity, minHeight: 180)
            case .tooLarge(let bytes):
                ArtifactFileFicha(
                    name: selected?.name ?? "artefato",
                    subtitle: "grande demais para visualizar aqui · \(ArtifactViewer.byteLabel(bytes))"
                )
            case .failed(let message):
                Text(message)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.domOperacional)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .loaded(let item, let content):
                ArtifactPreviewContent(item: item, content: content)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .atlasCard()
    }

    func loading(_ text: String) -> some View {
        VStack(spacing: 10) {
            BreathingDiamond(size: 10, reduceMotion: reduceMotion)
            Text(text)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    func evidenceEmpty(
        title: String,
        subtitle: String?,
        identifier: String,
        spoken: String
    ) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.title2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text(title)
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(36)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spoken)
        .accessibilityIdentifier(identifier)
    }

    var unavailableSpokenLabel: String {
        var parts = ["sem artefatos nesta execução"]
        if let reason = TraceEvidenceCopy.unavailableReason(artifacts?.reason) {
            parts.append(reason)
        }
        return parts.joined(separator: ", ")
    }

    func load(_ item: AtlasTraceArtifacts.Item) async {
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
}

enum ArtifactPreviewState {
    case idle
    case loading
    case loaded(AtlasTraceArtifacts.Item, AtlasArtifactContent)
    case tooLarge(Int)
    case failed(String)
}
