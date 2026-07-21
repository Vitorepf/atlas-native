import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS ConversationChrome

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
                accessibilityLabel: ComposerSheetJudgment.modeLabel(key: key, title: label, selected: isSelected),
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
        .accessibilityLabel(ComposerSheetJudgment.workspaceSheetSpokenLabel)
        .accessibilityValue(
            ComposerSheetJudgment.workspaceSheetFace(count: workspaces.count).productWord
        )
        .accessibilityHint(ComposerSheetJudgment.workspaceSheetHint)
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
            accessibilityLabel: ComposerSheetJudgment.workspaceLabel(
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
        .accessibilityLabel(ComposerSheetJudgment.modeSheetSpokenLabel)
        .accessibilityValue(ComposerSheetJudgment.modeFace(key: selected).productWord)
        .accessibilityHint(ComposerSheetJudgment.modeSheetHint)
    }
}

extension EffortSheet {
    func effortA11yBind<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityIdentifier(A11yID.effortSheet)
            .accessibilityLabel(ComposerEffortJudgment.effortSheetLabel)
            .accessibilityHint(ComposerEffortJudgment.effortSheetHint)
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
