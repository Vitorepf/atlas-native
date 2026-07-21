import AtlasCore
import Foundation
import PhotosUI
import SwiftUI

// Cycle 032 fuse → ConversationComposer.swift

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
        composerShell
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerShellPadding: some View {
        composerShellVBox
            .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: model.isSending)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
            .background(composerFadeBackground)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerShellVBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
    }
}

extension ConversationComposer {
    var composerShell: some View {
        composerShellPadding
    }
}

extension ConversationComposer {
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

extension ConversationComposer {
    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }
}

extension ConversationComposer {
    var composerFadeBackground: some View {
        LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

extension ConversationComposer {
    func dismissKeyboard() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
        }
    }
}

extension ConversationComposer {
    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }
}

enum ConversationComposerA11y {
    static func spokenCard(expanded: Bool, draftCount: Int, queueCount: Int, isSending: Bool) -> String {
        var parts = ["compositor"]
        if expanded { parts.append("expandido") }
        if draftCount > 0 {
            parts.append("\(draftCount) anexo\(draftCount == 1 ? "" : "s")")
        }
        if queueCount > 0 {
            parts.append("\(queueCount) na fila")
        }
        if isSending { parts.append("enviando") }
        return parts.joined(separator: ", ")
    }

    static let cardHint = "escreve, anexa e envia; fila e execução viva aparecem quando publicadas"
}
