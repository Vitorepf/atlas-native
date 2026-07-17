import SwiftUI
import PhotosUI
import UIKit
import AtlasCore

// Seletores do composer (modo / anexos / workspace) — peel de ConversationChrome.

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    private let modes = [
        ("geral", "Geral", "conversa e raciocínio amplos"),
        ("operacional", "Operacional", "tarefas do dia, decisões, execução"),
        ("autônomos", "Autônomos", "obras longas, agentes em background"),
        ("programação", "Programação", "código em um ou vários repos"),
    ]
    var body: some View {
        SheetShell(title: "Modo") {
            ForEach(modes, id: \.0) { key, label, sub in
                SheetRow(label: label, sub: sub, selected: key == selected) {
                    selected = key; UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                }
            }
        }
    }
}

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado
// são capacidades reais, mas não ocupam a superfície de escrita o tempo todo.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SheetShell(title: "Adicionar") {
            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                ComposerAttachmentRow(
                    icon: "photo",
                    title: "Foto",
                    subtitle: "Escolher da biblioteca"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("escolher foto")

            Button {
                choose(onChooseCamera)
            } label: {
                ComposerAttachmentRow(
                    icon: "camera",
                    title: "Câmera",
                    subtitle: "Capturar agora"
                )
            }
            .buttonStyle(.plain)

            Button {
                choose(onChooseFile)
            } label: {
                ComposerAttachmentRow(
                    icon: "doc",
                    title: "Arquivo",
                    subtitle: "PDF, texto, código ou dados"
                )
            }
            .buttonStyle(.plain)

            Button {
                let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
                dismiss()
                guard let text, !text.isEmpty else { return }
                Task { @MainActor in onPaste(text) }
            } label: {
                ComposerAttachmentRow(
                    icon: "doc.on.clipboard",
                    title: "Colar contexto",
                    subtitle: "Adicionar texto da área de transferência"
                )
            }
            .buttonStyle(.plain)
        }
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil { dismiss() }
        }
    }

    private func choose(_ action: @escaping @MainActor () -> Void) {
        dismiss()
        Task { @MainActor in action() }
    }
}
