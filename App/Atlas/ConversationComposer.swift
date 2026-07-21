import AtlasCore
import Foundation
import PhotosUI
import SwiftUI
import UIKit

// Cycle 044 fuse → ConversationComposer.swift

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
            withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) { focused.wrappedValue = false }
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

extension ConversationComposer {
    var composerCardSpokenLabel: String {
        ConversationComposerA11y.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }
}

extension ConversationComposer {
    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            composerCardBody
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.82), value: model.drafts)
        // Contain without fused label: input/send/attach stay individually focusable.
        .accessibilityElement(children: .contain)
        .accessibilityHint(ConversationComposerA11y.cardHint)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerAttachmentOnly: some View {
        composerAttachmentStrip
    }
}

extension ConversationComposer {
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
}

extension ConversationComposer {
    @ViewBuilder
    var composerStripToolbar: some View {
        composerAttachmentOnly
        composerToolbarOnly
    }
}

// Keyboard grabber — morto. Teclado dispensa no scroll / gesto da sheet.
// (A barra "fechar" lia como chrome de card e quebrava a pílula do grafo.)

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyGrabber: some View {
        EmptyView()
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyLive: some View {
        liveExecutionSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyQueue: some View {
        queueChipSection
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyStrip: some View {
        composerStripToolbar
    }
}

extension ConversationComposer {
    @ViewBuilder
    var composerCardBody: some View {
        composerCardBodyLive
        composerCardBodyQueue
        composerCardBodyGrabber
        composerCardBodyStrip
    }
}

extension ConversationComposer {
    var composerCardSheetFlagArgs: (
        mode: Binding<String>,
        showModeSheet: Binding<Bool>,
        showWorkspaceSheet: Binding<Bool>,
        showEffortSheet: Binding<Bool>,
        showQueueSheet: Binding<Bool>,
        showAttachmentSheet: Binding<Bool>,
        showCamera: Binding<Bool>,
        showFileImporter: Binding<Bool>,
        pickedPhoto: Binding<PhotosPickerItem?>
    ) {
        (
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showEffortSheet: $showEffortSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto
        )
    }
}

extension ConversationComposer {
    var composerCardSheetTraceArgs: (
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        (
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace
        )
    }
}

extension ConversationComposer {
    func composerCardSheets<V: View>(_ card: V) -> some View {
        let flags = composerCardSheetFlagArgs
        let traces = composerCardSheetTraceArgs
        return card.conversationComposerSheets(
            model: model,
            session: session,
            mode: flags.mode,
            showModeSheet: flags.showModeSheet,
            showWorkspaceSheet: flags.showWorkspaceSheet,
            showEffortSheet: flags.showEffortSheet,
            showQueueSheet: flags.showQueueSheet,
            showAttachmentSheet: flags.showAttachmentSheet,
            showCamera: flags.showCamera,
            showFileImporter: flags.showFileImporter,
            pickedPhoto: flags.pickedPhoto,
            reviewTrace: traces.reviewTrace,
            artifactTrace: traces.artifactTrace,
            steerTrace: traces.steerTrace,
            onSteerSubmit: submitSteer
        )
    }
}

extension ConversationComposer {
    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
}

extension ConversationComposer {
    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }
}

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var queueChipSection: some View {
        if !model.queuedMessages.isEmpty {
            queueChipA11y(queueChipButton)
        }
    }
}

extension ConversationComposer {
    @ViewBuilder
    func queueChipA11y<V: View>(_ button: V) -> some View {
        button
            .padding(.bottom, expanded ? 0 : 8)
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityLabel(queueAccessibilityLabel)
            .accessibilityHint("abre a folha para enviar agora ou remover da fila")
            .accessibilityIdentifier(A11yID.queueChip)
            .accessibilityAddTraits(.isButton)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var queueChipButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            showQueueSheet = true
        } label: {
            queueChipLabelView
        }
        .buttonStyle(PressableScale())
    }
}

extension ConversationComposer {
    var queueChipLabel: String {
        let n = model.queuedMessages.count
        return n == 1 ? "Fila · 1" : "Fila · \(n)"
    }

    var queueAccessibilityLabel: String {
        let n = model.queuedMessages.count
        return n == 1
            ? "1 mensagem na fila durante a execução"
            : "\(n) mensagens na fila durante a execução"
    }
}

extension ConversationComposer {
    var queueChipLabelView: some View {
        Text(queueChipLabel)
            .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 12).padding(.vertical, 5)
            .frame(minHeight: 44)
            .contentShape(Capsule())
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
    }
}

extension ConversationComposer {
    var keyboardGrabberBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.textTertiary.opacity(0.55))
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity, minHeight: 44) // HIG hit target for dismiss
            .contentShape(Rectangle())
    }
}

extension ConversationComposer {
    func keyboardGrabberGestures<V: View>(_ bar: V) -> some View {
        bar
            .onTapGesture { dismissKeyboard() }
            .gesture(
                DragGesture(minimumDistance: 6)
                    .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
            )
            .accessibilityLabel("fechar teclado")
            .accessibilityHint("toque ou arraste para baixo para dispensar o teclado")
            .accessibilityAddTraits(.isButton)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var keyboardGrabber: some View {
        if focused.wrappedValue {
            keyboardGrabberGestures(keyboardGrabberBar)
        }
    }
}

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSeparator: some View {
        Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
            .padding(.bottom, expanded ? 0 : 8)
            .accessibilityHidden(true)
    }
}

extension ConversationComposer {
    @ViewBuilder
    var liveExecutionSection: some View {
        if let live = liveBubble {
            ExecutingStrip(
                bubble: live,
                reduceMotion: reduceMotion,
                onStop: { model.cancel() },
                onSteer: live.traceId.map { trace in { steerTrace = ConversationSteerTraceRef(id: trace) } }
            )
                .padding(.top, expanded ? 0 : 4)
                .padding(.bottom, expanded ? 0 : 8)
                .transition(.opacity)
            liveExecutionSeparator
        }
    }
}

extension ConversationComposer {
    func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        // Haptic lives on SteerInteractionSheet Enviar (medium) — avoid double fire.
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }
}

extension ConversationComposer {
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


// Cycle 043 fuse → DraftStrip.swift

// Strip de anexos do composer — renderiza LocalDraft e nada mais

struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if drafts.isEmpty {
            EmptyView()
        } else {
            draftThumbs
        }
    }
}

extension DraftStrip {
    var draftThumbLoop: some View {
        HStack(spacing: 12) {
            ForEach(drafts) { d in
                DraftThumb(draft: d, reduceMotion: reduceMotion,
                           onRemove: onRemove, onFailedTap: onFailedTap)
                    .transition(reduceMotion ? .opacity
                                : .scale(scale: 0.86).combined(with: .opacity))
            }
        }
        .padding(.top, 6).padding(.trailing, 6)
    }
}

extension DraftStrip {
    var draftThumbs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            draftThumbLoop
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
        // Contain without strip label: each DraftThumb keeps its own a11y node.
        .accessibilityElement(children: .contain)
        .animation(
            reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.82),
            value: drafts.map(\.id)
        )
    }
}
