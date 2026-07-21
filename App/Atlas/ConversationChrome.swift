import SwiftUI
import AtlasCore
import PhotosUI

// IDLE-COMPRESS ConversationChrome

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

extension ComposerAttachmentsSheet {
    var attachmentsSheetChrome: some View {
        SheetShell(title: "Adicionar") {
            attachmentOptions
        }
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenSheet)
        .accessibilityHint(ComposerAttachmentsA11y.spokenSheetHint)
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
            .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
            .accessibilityHint(pasteboardText == nil
                ? ComposerAttachmentsA11y.spokenPasteDisabledHint
                : ComposerAttachmentsA11y.spokenPasteHint)
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
        .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
        .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
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
        .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
        .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOption: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
        .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}

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

enum ComposerSheetA11y {
    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"
    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static var effortSheetHint: String { ComposerEffortJudgment.effortSheetHint }
    static let workspaceSheetHint = "escolhe a pasta do próximo envio entre as conversas carregadas"
    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"

    static func modeLabel(_ key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }

    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    /// WAVE-076: effort sheet spoken from ComposerEffortJudgment.
    static func effortLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        ComposerEffortJudgment.spokenSheetLabel(effort, selected: selected)
    }

    static func spokenEffort(_ effort: AtlasComputeEffort) -> String {
        ComposerEffortJudgment.spokenSheet(effort)
    }

    static func effortSubtitle(_ effort: AtlasComputeEffort) -> String {
        ComposerEffortJudgment.subtitle(effort)
    }
}

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

