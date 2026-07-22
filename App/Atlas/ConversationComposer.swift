import SwiftUI
import AtlasCore
import PhotosUI

// GOD-RESTRUCTURE: ConversationComposer host+body fused

// MARK: - Host

struct ConversationComposer: View {
    var model: ConversationModel
    var session: AtlasSession
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding

    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    @Binding var showCamera: Bool
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(composerFadeBackground)
    }

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar. Estado de composição ⊃ estado de foco.
    var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Presence-ongoing bubble (WAVE-027) — not streaming-only (paused/reconnect keep strip).
    var liveBubble: ChatBubble? {
        ConversationExecutionPhase.selectPresenceBubble(from: model.bubbles)
    }

    var composerFadeBackground: some View {
        LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

// MARK: - Body

// MARK: - Actions

extension ConversationComposer {
    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

}

// MARK: - Card surface

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }

    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            liveExecutionSection
            queueChipSection
            // Grabber morto (teclado dispensa no scroll) — EmptyView removed.
            composerAttachmentStrip
            composerToolbarOnly
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(composerCardSpokenLabel)
        .accessibilityHint(ComposerToolbarJudgment.spokenCardHint)
    }

    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }

    var composerCardSpokenLabel: String {
        ComposerToolbarJudgment.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }

    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }

    @ViewBuilder
    var composerToolbarOnly: some View {
        ComposerToolbar(
            model: model,
            reduceMotion: reduceMotion,
            focused: focused,
            expanded: expanded,
            mode: mode,
            liveBubble: liveBubble,
            onAttach: { showAttachmentSheet = true },
            onShowWorkspace: { showWorkspaceSheet = true },
            onShowMode: { showModeSheet = true },
            onShowEffort: { showEffortSheet = true },
            onSend: send
        )
    }

    /// Foco = forma (cápsula → cartão), não borda dourada gritante.
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(AtlasTheme.separator.opacity(0.95), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.16), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous)
                .fill(AtlasTheme.surface)
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(AtlasTheme.separator, lineWidth: 1)
                )
        }
    }
}

// MARK: - Live strip

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSection: some View {
        if let live = liveBubble {
            ExecutingStrip(
                bubble: live,
                reduceMotion: reduceMotion,
                onStop: { model.cancel() },
                onSteer: live.traceId.map { trace in { steerTrace = ConversationSteerTraceRef(id: trace) } },
                onChoose: { jobId, optionId in
                    Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                }
            )
            .padding(.top, expanded ? 0 : 4)
            .padding(.bottom, expanded ? 0 : 8)
            .transition(.opacity)
            Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                .padding(.bottom, expanded ? 0 : 8)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Queue chip

extension ConversationComposer {
    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                showQueueSheet = true
            } label: {
                Text(queueChipLabel)
                    .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .background(Capsule().fill(AtlasTheme.goldVeil)
                        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            }
            .buttonStyle(PressableScale())
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("abre a folha para enviar agora ou remover da fila")
            .accessibilityValue(
                ComposerQueueJudgment.face(from: model.queuedMessages).productWord
            )
            .accessibilityIdentifier(A11yID.queueChip)
        }
    }

    /// WAVE-051: head-aware chip (not count-only).
    var queueChipLabel: String {
        ComposerQueueJudgment.productChip(from: model.queuedMessages)
    }

    var queueAccessibilityLabel: String {
        ComposerQueueJudgment.spokenChip(from: model.queuedMessages)
    }
}

// MARK: - Sheet host

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        card.conversationComposerSheets(
            model: model,
            session: session,
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}

// MARK: - Steer submit

extension ConversationComposer {
    func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }

    func steerReceipt(for traceId: TraceID) -> AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }

    func steerReceiptText(_ receipt: AtlasInteractionSteerResponse) -> String {
        receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"
    }
}

// MARK: - Draft strip

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void
    var uploadPercent: Double? = nil

    private var stripFace: ComposerDraftStripFace {
        ComposerDraftJudgment.stripFace(drafts: drafts, uploadPercent: uploadPercent)
    }

    var body: some View {
        if stripFace == .silence {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // WAVE-046/086: failed-first attention rank.
                    ForEach(ComposerDraftJudgment.rankDrafts(drafts)) { d in
                        DraftThumb(
                            draft: d,
                            reduceMotion: reduceMotion,
                            onRemove: onRemove,
                            onFailedTap: onFailedTap
                        )
                        .transition(
                            reduceMotion
                                ? .opacity
                                : .scale(scale: 0.86).combined(with: .opacity)
                        )
                    }
                }
                .padding(.top, 6).padding(.trailing, 6)
            }
            .scrollClipDisabled()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                ComposerDraftJudgment.spokenStrip(drafts: drafts, uploadPercent: uploadPercent)
            )
            .accessibilityValue(stripFace.productWord)
            .animation(
                reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86),
                value: drafts.map(\.id)
            )
        }
    }
}

// MARK: - Draft thumb

@MainActor
enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString); return ui
    }
}

extension DraftThumb {
    var thumbFace: ComposerDraftThumbFace {
        ComposerDraftJudgment.thumbFace(draft)
    }

    func removeButtonA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(ComposerDraftJudgment.spokenRemove(draft))
            .accessibilityHint(ComposerDraftJudgment.spokenRemoveHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
    }
}

extension DraftThumb {
    @ViewBuilder
    var removeButtonChrome: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(18)
            .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
            .padding(8)
            .contentShape(Circle())
    }
}

extension DraftThumb {
    @ViewBuilder var removeButton: some View {
        if draft.state != .subindo {
            removeButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRemove(draft.id)
                } label: {
                    removeButtonChrome
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
            )
        }
    }
}

extension DraftThumb {
    @ViewBuilder var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.94)))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill").atlasSans(16)
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading).padding(6)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.9)))
        }
    }
}

extension DraftThumb {
    func thumbContentA11y<V: View>(_ framed: V) -> some View {
        framed
            .overlay { stateVeil }
            .onTapGesture {
                if let m = failedMessage { onFailedTap("falhou: \(m)") }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ComposerDraftJudgment.spokenThumb(draft))
            .accessibilityValue(
                failedMessage.map { ComposerDraftJudgment.spokenFailedValue($0) } ?? thumbFace.productWord
            )
            .accessibilityHint(failedMessage != nil ? ComposerDraftJudgment.spokenFailedHint : "")
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: draft.state)
    }
}

extension DraftThumb {
    var thumbFrame: some View {
        thumb
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .stroke(
                        failedMessage != nil
                            ? AtlasTheme.domOperacional.opacity(0.8)
                            : AtlasTheme.separator,
                        lineWidth: failedMessage != nil ? 1.5 : 1
                    )
            )
    }
}

extension DraftThumb {
    var thumbContent: some View {
        thumbContentA11y(thumbFrame)
    }
}

extension DraftThumb {
    var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }
}

extension DraftThumb {
    @ViewBuilder var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").atlasSans(20).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(AtlasTheme.surfaceHi)
        }
    }
}

struct DraftThumb: View {
    let draft: LocalDraft
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumbContent
            removeButton
        }
    }
}

// MARK: - ConversationChrome

// MARK: - Sheet shell

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        sheetPresentationChrome(sheetScrollBody)
    }

    var sheetScrollBody: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
    }

    var sheetHandle: some View {
        RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
            .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            .accessibilityHidden(true)
    }

    var sheetTitle: some View {
        Text(title)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 14)
            .accessibilityAddTraits(.isHeader)
    }

    func sheetPresentationChrome<Inner: View>(_ content: Inner) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationBackground(AtlasTheme.bg)
            .presentationDragIndicator(.hidden)
    }
}

// MARK: - Attachments sheet

extension ComposerAttachmentsSheet {
    var attachmentsSheetChrome: some View {
        SheetShell(title: "Adicionar") {
            attachmentOptions
        }
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerDraftJudgment.spokenAttachSheet)
        .accessibilityHint(ComposerDraftJudgment.spokenAttachSheetHint)
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil { dismiss() }
        }
    }
}

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        attachmentPhotoOptions
        attachmentFileAndPaste
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonA11y<V: View>(_ button: V) -> some View {
        button
            .disabled(pasteboardText == nil)
            .accessibilityLabel(ComposerDraftJudgment.spokenPaste(hasText: pasteboardText != nil))
            .accessibilityHint(pasteboardText == nil
                ? ComposerDraftJudgment.spokenPasteDisabledHint
                : ComposerDraftJudgment.spokenPasteHint)
            .accessibilityIdentifier(A11yID.attachmentPaste)
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonAction() {
        guard let text = pasteboardText else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in onPaste(text) }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileOption: some View {
        Button { choose(onChooseFile) } label: {
            ComposerAttachmentRow(icon: "doc", title: "Arquivo", subtitle: "PDF, texto, código ou dados")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerDraftJudgment.spokenFile)
        .accessibilityHint(ComposerDraftJudgment.spokenFileHint)
        .accessibilityIdentifier(A11yID.attachmentFile)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        attachmentFileOption
        pasteButton
    }

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        pasteButtonA11y(
            Button {
                pasteButtonAction()
            } label: {
                pasteButtonLabel
            }
            .buttonStyle(.plain)
        )
    }
}

extension ComposerAttachmentsSheet {
    var pasteButtonLabel: some View {
        ComposerAttachmentRow(
            icon: "doc.on.clipboard",
            title: "Colar contexto",
            subtitle: pasteboardText == nil
                ? "Nada na área de transferência"
                : "Adicionar texto da área de transferência"
        )
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentCameraOption: some View {
        Button { choose(onChooseCamera) } label: {
            ComposerAttachmentRow(icon: "camera", title: "Câmera", subtitle: "Capturar agora")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerDraftJudgment.spokenChooseCamera)
        .accessibilityHint(ComposerDraftJudgment.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOption: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerDraftJudgment.spokenPhoto)
        .accessibilityHint(ComposerDraftJudgment.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}

// MARK: - Attachments host

struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        attachmentsSheetChrome
    }
}

// MARK: - Attachment row

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .atlasSans(17, .medium)
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}

extension ComposerAttachmentRow {
    var attachmentRowTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Sheets host (row · workspace · mode · effort)

// MARK: - Attachment row body

extension ComposerAttachmentRow {
    var attachmentRowCopy: some View {
        HStack(spacing: 14) {
            attachmentRowIcon
            attachmentRowTextStack
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        attachmentRowCopy
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ComposerDraftJudgment.spokenAttachmentRow(title: title, subtitle: subtitle))
    }
}

extension ModeSheet {
    var modeFootnote: some View {
        Text(ComposerSheetJudgment.modeFootnote)
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

extension ModeSheet {
    var modeRows: some View {
        ForEach(Self.modes, id: \.0) { key, label in
            let isSelected = key == selected
            SheetRow(
                label: label,
                sub: ComposerSheetJudgment.modeFootnote,
                selected: isSelected,
                accessibilityLabel: ComposerSheetJudgment.spokenModeLabel(key: key, title: label, selected: isSelected),
                accessibilityIdentifier: A11yID.modeRow(key)
            ) {
                selected = key
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                dismiss()
            }
        }
    }
}

extension ModeSheet {
    /// WAVE-081: single source on ComposerSheetJudgment.
    static var modes: [(String, String)] {
        ComposerSheetJudgment.modes.map { ($0.key, $0.title) }
    }
}

// MARK: - Workspace sheet

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                workspaceEmptyLabel
            } else {
                workspaceList
            }
        }
        .accessibilityIdentifier(A11yID.workspaceSheet)
        .accessibilityLabel(ComposerSheetJudgment.spokenWorkspaceSheet)
        .accessibilityValue(
            ComposerSheetJudgment.workspaceSheetFace(count: workspaces.count).productWord
        )
        .accessibilityHint(ComposerSheetJudgment.spokenWorkspaceSheetHint)
    }
}

extension WorkspaceSheet {
    var workspaceEmptyLabel: some View {
        Text("Nenhum workspace nas conversas carregadas")
            .atlasSans(15)
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .accessibilityLabel(ComposerSheetJudgment.workspaceEmpty)
    }
}

extension WorkspaceSheet {
    var workspaceListHeader: some View {
        Text("pastas das conversas carregadas · vale no próximo envio")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityAddTraits(.isHeader)
    }

    func workspaceCountLine(_ count: Int) -> String {
        ComposerSheetJudgment.workspaceCountLine(count)
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    var workspaceList: some View {
        workspaceListHeader
        ForEach(workspaces) { ws in
            workspaceRow(ws)
        }
    }
}

extension WorkspaceSheet {
    func workspaceRowPick(_ ws: Workspace) {
        onPick(ws)
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRowBuild(_ ws: Workspace, isSelected: Bool) -> some View {
        SheetRow(
            label: ws.name,
            sub: workspaceCountLine(ws.count),
            selected: isSelected,
            accessibilityLabel: ComposerSheetJudgment.spokenWorkspaceLabel(
                name: ws.name, count: ws.count, selected: isSelected
            ),
            accessibilityIdentifier: A11yID.workspaceRow(ws.id)
        ) {
            workspaceRowPick(ws)
        }
    }
}

extension WorkspaceSheet {
    @ViewBuilder
    func workspaceRow(_ ws: Workspace) -> some View {
        workspaceRowBuild(ws, isSelected: ws.name == current)
    }
}

// MARK: - Mode sheet

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) var dismiss  // interno: peels em outros arquivos usam
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        SheetShell(title: "Modo") {
            modeFootnote
            modeRows
        }
        .accessibilityIdentifier(A11yID.modeSheet)
        .accessibilityLabel(ComposerSheetJudgment.spokenModeSheet)
        .accessibilityValue(ComposerSheetJudgment.modeFace(key: selected).productWord)
        .accessibilityHint(ComposerSheetJudgment.spokenModeSheetHint)
    }
}

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel(ComposerEffortJudgment.spokenEffortSheet)
            .accessibilityHint(ComposerEffortJudgment.spokenEffortSheetHint)
    }
}

extension EffortSheet {
    var effortFootnoteCopy: some View {
        Text("vale para o próximo envio; automático deixa o Atlas Decide escolher")
            .atlasSans(12)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
            .accessibilityHidden(true)
    }
}

// MARK: - ConversationComposerSheetsModifier

// MARK: - Public View API (conversationComposerSheets)

extension View {
    func conversationComposerSheets(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierForward(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

// MARK: - Modifier host

struct ConversationComposerSheetsModifier: ViewModifier {
    var model: ConversationModel
    var session: AtlasSession
    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showEffortSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var showCamera: Bool
    @Binding var showFileImporter: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    let onSteerSubmit: (TraceID, String, AtlasInteractionSteerScope) -> Void

    func body(content: Content) -> some View {
        modifierChain(on: content)
    }
}

extension View {
    func conversationComposerSheetsModifier(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierWrap(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

extension ConversationComposerSheetsModifier {
    func modifierChain(on content: Content) -> some View {
        handoffAndQueueObservers(on:
            attachmentModifiers(on:
                reviewSteerQueueSheets(on:
                    modeEffortSheets(on: content)
                )
            )
        )
    }
}

extension ConversationComposerSheetsModifier {
    func modeEffortSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
            .sheet(isPresented: $showEffortSheet) { EffortSheet(model: model) }
    }
}

extension ConversationComposerSheetsModifier {
    func handoffAndQueueObservers<Content: View>(on content: Content) -> some View {
        content
            .onChange(of: model.queuedMessages.isEmpty) { _, empty in
                if empty { showQueueSheet = false }
            }
            .onChange(of: model.latestSurfaceHandoff?.id) {
                guard let h = model.latestSurfaceHandoff, h.status == "ready" else { return }
                let destino = atlasSurfaceLabel(h.toSurface)
                model.toast = "Pronto no \(destino) — mesma conversa, mesma sessão."
            }
    }
}

extension ConversationComposerSheetsModifier {
    func changeReviewSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $reviewTrace) { ref in
                ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $artifactTrace) { ref in
                ArtifactSheet(reviews: model.reviews, traceId: ref.id)
            }
    }
}

extension ConversationComposerSheetsModifier {
    func queueSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showQueueSheet) {
                QueuedFollowUpsSheet(model: model)
            }
    }
}

extension ConversationComposerSheetsModifier {
    func reviewSteerQueueSheets<Content: View>(on content: Content) -> some View {
        steerSheet(on: queueSheet(on: changeReviewSheets(on: content)))
    }
}

extension ConversationComposerSheetsModifier {
    func steerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $steerTrace) { ref in
                SteerInteractionSheet(
                    traceId: ref.id,
                    model: model
                ) { instruction, scope in
                    onSteerSubmit(ref.id, instruction, scope)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}

// MARK: - Sheet binders / trace refs

extension View {
    func conversationComposerSheetsModifierInit(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        modifier(ConversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        ))
    }
}

extension View {
    func conversationComposerSheetsModifierWrap(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifierInit(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

extension View {
    func conversationComposerSheetsModifierForward(
        model: ConversationModel,
        session: AtlasSession,
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>,
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>,
        onSteerSubmit: @escaping (TraceID, String, AtlasInteractionSteerScope) -> Void
    ) -> some View {
        conversationComposerSheetsModifier(
            model: model,
            session: session,
            mode: mode,
            showModeSheet: showModeSheet,
            showWorkspaceSheet: showWorkspaceSheet,
            showEffortSheet: showEffortSheet,
            showQueueSheet: showQueueSheet,
            showAttachmentSheet: showAttachmentSheet,
            showCamera: showCamera,
            showFileImporter: showFileImporter,
            pickedPhoto: pickedPhoto,
            reviewTrace: reviewTrace,
            artifactTrace: artifactTrace,
            steerTrace: steerTrace,
            onSteerSubmit: onSteerSubmit
        )
    }
}

struct ConversationReviewTraceRef: Identifiable { let id: TraceID }
struct ConversationSteerTraceRef: Identifiable { let id: TraceID }

// MARK: - Attachment chain + camera cover

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentModifiers<Content: View>(on content: Content) -> some View {
        attachmentImporters(on: attachmentSheets(on: content))
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentImporters<Content: View>(on content: Content) -> some View {
        content
            .conversationCameraCover(model: model, showCamera: $showCamera)
            .fileImporter(isPresented: $showFileImporter,
                          allowedContentTypes: [.pdf, .text, .sourceCode, .json, .commaSeparatedText]) { result in
                if case .success(let url) = result { model.addFile(url: url) }
            }
            .onChange(of: pickedPhoto) {
                handlePickedPhotoChange()
            }
    }
}

extension ConversationComposerSheetsModifier {
    func handlePickedPhotoChange() {
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

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentPickerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showAttachmentSheet) {
                ComposerAttachmentsSheet(
                    pickedPhoto: $pickedPhoto,
                    onChooseFile: { showFileImporter = true },
                    onChooseCamera: { showCamera = true },
                    onPaste: { model.addClipboard(text: $0) }
                )
            }
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func attachmentSheets<Content: View>(on content: Content) -> some View {
        workspacePickerSheet(on:
            attachmentPickerSheet(on: content)
        )
    }
}

extension ConversationComposerSheetsModifier {
    @ViewBuilder
    func workspacePickerSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showWorkspaceSheet) {
                WorkspaceSheet(workspaces: session.workspaces, current: model.workspaceName) { ws in
                    model.workspaceSlug = ws.id
                    model.workspaceName = ws.name
                    model.workspacePath = session.workspaceFullPath(forKey: ws.id)
                }
            }
    }
}

extension View {
    func conversationCameraCover(model: ConversationModel, showCamera: Binding<Bool>) -> some View {
        modifier(ConversationCameraCoverModifier(model: model, showCamera: showCamera))
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverA11y<Content: View>(_ content: Content) -> some View {
        content
            .ignoresSafeArea()
            .accessibilityIdentifier(A11yID.cameraPicker)
            .accessibilityLabel(ComposerDraftJudgment.spokenCameraSurface)
            .accessibilityHint(ComposerDraftJudgment.spokenCameraHint)
            .transaction { txn in
                if reduceMotion { txn.disablesAnimations = true }
            }
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverOnCapture(data: Data) {
        model.addImage(
            data: data,
            suggestedName: nil,
            mimeType: "image/jpeg",
            identity: UUID().uuidString,
            source: "camera"
        )
    }
}

extension ConversationCameraCoverModifier {
    func cameraCoverOnCaptureFailed() {
        model.toast = ComposerDraftJudgment.captureFailedToast
    }
}

extension ConversationCameraCoverModifier {
    var cameraCoverContent: some View {
        cameraCoverA11y(
            CameraPicker(
                onCapture: { cameraCoverOnCapture(data: $0) },
                onCaptureFailed: cameraCoverOnCaptureFailed,
                onCancel: {}
            )
        )
    }
}

struct ConversationCameraCoverModifier: ViewModifier {
    var model: ConversationModel
    @Binding var showCamera: Bool
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showCamera) {
                cameraCoverContent
            }
    }
}
