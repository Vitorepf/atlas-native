import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Folhas e chrome de apresentação da conversa — peels de ConversationView
// (régua anti-inchaço). Callbacks e A11yIDs idênticos; zero mudança de rota.

struct ConversationReviewTraceRef: Identifiable { let id: TraceID }
struct ConversationSteerTraceRef: Identifiable { let id: TraceID }

// MARK: - Índice da conversa

struct ConversationOutlineSheet: View {
    let bubbles: [ChatBubble]

    var body: some View {
        SheetShell(title: "Índice da conversa") {
            ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                ConversationOutlineRow(index: index + 1, bubble: bubble)
            }
        }
    }
}

struct ConversationOutlineRow: View {
    let index: Int
    let bubble: ChatBubble

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(String(format: "%02d", index))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .contentTransition(.numericText())
            VStack(alignment: .leading, spacing: 3) {
                Text(bubble.role == "user" ? "Você" : "Atlas")
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(snippet)
                    .font(.system(.footnote))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 10)
        .accessibilityIdentifier(A11yID.conversationOutlineRow(index))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("turno \(index), \(bubble.role == "user" ? "você" : "Atlas"), \(snippet)")
    }

    private var snippet: String {
        let text = AtlasMarkdown.plainText(bubble.text)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "sem texto visível" : String(text.prefix(140))
    }
}

// MARK: - Recibo de continuidade + selos

struct ConversationHandoffReceipt: View {
    let handoff: AtlasAiSurfaceHandoff

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(handoff.status == "ready" ? AtlasTheme.accent : AtlasTheme.textTertiary)
            VStack(alignment: .leading, spacing: 2) {
                Text("Continuidade enviada para \(surfaceLabel(handoff.toSurface))")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("\(handoff.status) · mesma thread \(String(handoff.threadId.prefix(8)))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 2)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("recibo de continuidade para \(surfaceLabel(handoff.toSurface)), status \(handoff.status)")
    }

    private func surfaceLabel(_ raw: String) -> String {
        switch raw {
        case "atlas_desktop": return "Mac"
        case "atlas_terminal": return "Terminal"
        default: return raw
        }
    }
}

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10, weight: .semibold))
                Text(reduceMotion && confirming
                     ? "leitura atualizada"
                     : "visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
                    .font(AtlasFont.mono(11))
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
            .accessibilityLabel(confirming
                                ? "histórico salvo atualizado"
                                : "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
        }
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
    }
}

func atlasRelativeAgePT(since date: Date, now: Date = Date()) -> String {
    let seconds = max(0, Int(now.timeIntervalSince(date)))
    if seconds < 60 { return "menos de 1 min" }

    let minutes = seconds / 60
    if minutes < 60 { return "\(minutes) min" }

    let hours = minutes / 60
    if hours < 24 { return "\(hours)h" }

    let days = hours / 24
    return days == 1 ? "1 dia" : "\(days) dias"
}

// MARK: - Sheets do composer (modo / review / anexos / workspace / câmera)

extension View {
    /// Folhas e covers anexados ao card do composer — mesmos callbacks e a11y.
    func conversationComposerSheets(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        steerReceipt: @escaping (TraceID) -> AtlasInteractionSteerResponse?,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        modifier(ConversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            steerReceipt: steerReceipt,
            onSteerSubmit: onSteerSubmit
        ))
    }
}

private struct ConversationComposerSheetsModifier: ViewModifier {
    var model: ConversationModel
    var session: AtlasSession
    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var showCamera: Bool
    @Binding var showFileImporter: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    let steerReceipt: (TraceID) -> AtlasInteractionSteerResponse?
    let onSteerSubmit: (TraceID, String, AtlasInteractionSteerScope) -> Void

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
            .sheet(item: $reviewTrace) { ref in
                ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $artifactTrace) { ref in
                ArtifactSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $steerTrace) { ref in
                SteerInteractionSheet(
                    traceId: ref.id,
                    receipt: steerReceipt(ref.id)
                ) { instruction, scope in
                    onSteerSubmit(ref.id, instruction, scope)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showQueueSheet) {
                QueuedFollowUpsSheet(model: model)
            }
            .onChange(of: model.queuedMessages.isEmpty) { _, empty in
                if empty { showQueueSheet = false }
            }
            .onChange(of: model.latestSurfaceHandoff?.id) {
                guard let h = model.latestSurfaceHandoff, h.status == "ready" else { return }
                let destino = h.toSurface == "atlas_desktop" ? "Mac"
                            : h.toSurface == "atlas_terminal" ? "Terminal" : h.toSurface
                model.toast = "Pronto para abrir no \(destino) — mesma conversa, mesma sessão."
            }
            .sheet(isPresented: $showAttachmentSheet) {
                ComposerAttachmentsSheet(
                    pickedPhoto: $pickedPhoto,
                    onChooseFile: { showFileImporter = true },
                    onChooseCamera: { showCamera = true },
                    onPaste: { model.addClipboard(text: $0) }
                )
            }
            .sheet(isPresented: $showWorkspaceSheet) {
                WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                    model.workspaceSlug = ws.id
                    model.workspaceName = ws.name
                    model.workspacePath = session.workspaceFullPath(forKey: ws.id)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    model.addImage(data: data, suggestedName: nil,
                                   mimeType: "image/jpeg",
                                   identity: UUID().uuidString, source: "camera")
                }
                .ignoresSafeArea()
            }
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.pdf, .text, .sourceCode, .json, .commaSeparatedText]) { result in
                if case .success(let url) = result { model.addFile(url: url) }
            }
            .onChange(of: pickedPhoto) {
                guard let item = pickedPhoto else { return }
                pickedPhoto = nil
                Task {
                    guard let data = try? await item.loadTransferable(type: Data.self) else {
                        model.toast = "não consegui ler a foto"; return
                    }
                    let mime = item.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
                    model.addImage(data: data, suggestedName: nil, mimeType: mime,
                                   identity: item.itemIdentifier ?? UUID().uuidString)
                }
            }
    }
}
