import SwiftUI
import PhotosUI
import UIKit
import AtlasCore

// Sheets do composer (modo / anexos / workspace) + shell compartilhado.
// Turno editorial → EditorialTurn.swift; strip → DraftStrip.swift.

// MARK: - Sheets (seletores funcionais, tema Atlas)

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).padding(.bottom, 14)
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .presentationDragIndicator(.hidden)
    }
}

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    if let sub { Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary) }
                }
                Spacer()
                if selected { Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.accent) }
            }
            .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

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

private struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                Text(subtitle).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                Text("Nenhum workspace ainda").font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary).padding(.top, 40)
            } else {
                ForEach(workspaces) { ws in
                    SheetRow(label: ws.name, sub: "\(ws.count) conversas · main", selected: ws.name == current) {
                        onPick(ws); UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                    }
                }
            }
        }
    }
}
