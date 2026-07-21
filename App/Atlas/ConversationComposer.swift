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


// Cycle 043 fuse → CameraPicker.swift

// zero lógica além de entregar os bytes; o AtlasImaging normaliza depois.
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    var onCaptureFailed: () -> Void = {}
    var onCancel: () -> Void = {}
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeUIViewController(context: Context) -> UIImagePickerController {
        makeCameraPicker(context: context)
    }

    func updateUIViewController(_ vc: UIImagePickerController, context: Context) {
        applyReduceMotion(vc)
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }
}

/// Cancelar = silêncio total (nunca toast de anexo); falha só quando bytes não saem.

enum CameraPickerA11y {
    static let spokenSurface = "câmera para anexar foto"
    static let spokenHint = "confirme a captura para anexar; cancelar não adiciona nada"
    static let captureFailedToast = "não consegui capturar a foto"

    static let spokenChooseCamera = "capturar foto na câmera"
    static let spokenChooseCameraHint = "abre a câmera; nada é anexado até confirmar a captura"
}

extension CameraPicker.Coordinator {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.onCancel()
        parent.dismiss()
    }
}

extension CameraPicker {
    func makeCameraPicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        applyReduceMotion(picker)
        return picker
    }
}

extension CameraPicker {
    func applyReduceMotion(_ picker: UIImagePickerController) {
        if reduceMotion {
            picker.modalTransitionStyle = .crossDissolve
        }
    }
}

extension CameraPicker {
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.92) {
                parent.onCapture(data)
            } else {
                parent.onCaptureFailed()
            }
            parent.dismiss()
        }
    }
}


// Cycle 043 fuse → DraftThumb.swift

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

/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.

enum DraftThumbA11y {
    static func spokenRemove(_ draft: LocalDraft) -> String {
        DraftThumbA11yHints.spokenRemove(draft)
    }

    static let removeHint = DraftThumbA11yHints.removeHint
    static let failedHint = DraftThumbA11yHints.failedHint

    static func spokenFailedValue(_ message: String) -> String {
        DraftThumbA11yHints.spokenFailedValue(message)
    }
}

enum DraftThumbA11yHints {
    static let removeHint = "remove este anexo antes do envio"
    static let failedHint = "toque para ver o erro completo no aviso"

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        "remover anexo \(draft.fileName)"
    }
}

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
    func removeButtonA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
            .accessibilityAddTraits(.isButton)
    }
}

extension DraftThumb {
    @ViewBuilder
    var removeButtonChrome: some View {
        Image(systemName: "xmark.circle.fill")
            .atlasSans(18)
            .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
            .frame(width: 44, height: 44)
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

extension DraftThumbA11y {
    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }
}

extension DraftThumbA11y {
    static func spokenThumbReadyParts(_ draft: LocalDraft) -> [String]? {
        switch draft.state {
        case .pronto: return ["pronto para enviar"]
        case .subindo: return ["enviando"]
        default: return nil
        }
    }
}

extension DraftThumbA11y {
    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        if let ready = spokenThumbReadyParts(draft) { return ready }
        if case .falhou(let message) = draft.state {
            var parts = ["falhou"]
            if !message.isEmpty { parts.append(message) }
            return parts
        }
        return []
    }
}

extension DraftThumbA11y {
    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }
}

extension DraftThumb {
    func thumbContentA11y<V: View>(_ framed: V) -> some View {
        framed
            .overlay { stateVeil }
            .onTapGesture {
                if let m = failedMessage {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onFailedTap("falhou: \(m)")
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(DraftThumbA11y.spokenThumb(draft))
            .accessibilityValue(failedMessage.map { DraftThumbA11y.spokenFailedValue($0) } ?? "")
            .accessibilityHint(failedMessage != nil ? DraftThumbA11y.failedHint : "")
            .accessibilityAddTraits(failedMessage != nil ? .isButton : [])
            .modifier(DraftThumbFailedA11yAction(
                failedMessage: failedMessage,
                reduceMotion: reduceMotion,
                onFailedTap: onFailedTap
            ))
            .accessibilityIdentifier(A11yID.draft(draft.id))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: draft.state)
    }
}

/// VO activate for failed draft (mirrors onTapGesture retry path).
private struct DraftThumbFailedA11yAction: ViewModifier {
    let failedMessage: String?
    let reduceMotion: Bool
    let onFailedTap: (String) -> Void

    func body(content: Content) -> some View {
        if let m = failedMessage {
            content.accessibilityAction(named: "Ver falha do anexo") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFailedTap("falhou: \(m)")
            }
        } else {
            content
        }
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


// Cycle 044 fuse → ComposerToolbar.swift

// Toolbar do composer: paperclip + campo + trailing (enviar / processando / menu

struct ComposerToolbar: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding
    var expanded: Bool
    var mode: String
    var liveBubble: ChatBubble?
    var onAttach: () -> Void
    var onShowWorkspace: () -> Void
    var onShowMode: () -> Void
    var onShowEffort: () -> Void
    var onSend: () -> Void

    var body: some View {
        toolbarRow
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowAttach: some View {
        attachButton
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowField: some View {
        composerTextField
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowTrailing: some View {
        trailingControl
    }
}

extension ComposerToolbar {
    var toolbarRow: some View {
        HStack(spacing: 10) {
            toolbarRowAttach
            toolbarRowField
            toolbarRowTrailing
        }
        .accessibilityElement(children: .contain)
    }
}

extension ComposerToolbar {
    var canSubmitFromDraft: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || !model.drafts.isEmpty
    }
}

extension ComposerToolbar {
    var canSubmitWhileSending: Bool {
        !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension ComposerToolbar {
    var canSubmit: Bool {
        if model.isSending || liveBubble != nil {
            return canSubmitWhileSending
        }
        return canSubmitFromDraft
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var composerFieldPlaceholder: some View {
        Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
            .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
            .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.28), value: model.draftText.isEmpty)
            .accessibilityHidden(true)
    }
}

extension ComposerToolbar {
    var composerTextFieldInput: some View {
        TextField("", text: Binding(
            get: { model.draftText },
            set: { model.updateDraft($0) }
        ), axis: .vertical)
            .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent).lineLimit(1...6).focused(focused)
            .accessibilityIdentifier(A11yID.conversationInput)
            .accessibilityLabel(spokenInputLabel())
            .accessibilityHint(spokenInputHint())
    }
}

extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            composerFieldPlaceholder
            composerTextFieldInput
        }
    }
}

extension ComposerToolbar {
    var attachButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAttach()
        } label: {
            Image(systemName: "paperclip")
                .atlasSans(17, .medium)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("adicionar anexo")
        .accessibilityHint("abre foto, arquivo ou colar")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var isExecuting: Bool { model.isSending || liveBubble != nil }

    func spokenSendLabel(canSubmit: Bool) -> String {
        if canSubmit {
            return isExecuting ? "adicionar à fila" : "enviar ao Atlas"
        }
        return isExecuting
            ? "enviar indisponível, Atlas processando"
            : "enviar indisponível, sem mensagem nem anexo"
    }
}

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        canSubmit ? spokenSendHintReady() : spokenSendHintBlocked()
    }
}

extension ComposerToolbar {
    func spokenEffortLightLabel(_ effort: AtlasComputeEffort) -> String? {
        switch effort {
        case .auto: return "esforço automático, Atlas Decide escolhe"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        default: return nil
        }
    }
}

extension ComposerToolbar {
    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        if let light = spokenEffortLightLabel(effort) { return light }
        switch effort {
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        default: return "esforço automático, Atlas Decide escolhe"
        }
    }
}

extension ComposerToolbar {
    func spokenEffortHint() -> String {
        "abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "modo, esforço e workspace; \(spokenSendHint(canSubmit: false).lowercased())"
    }
}

extension ComposerToolbar {
    func spokenInputLabel() -> String {
        model.bubbles.isEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    func spokenInputHint() -> String {
        if canSubmit {
            return isExecuting ? "texto para a fila do próximo turno" : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }
}

extension ComposerToolbar {
    func spokenProcessingLabel() -> String { "Atlas processando" }
}

extension ComposerToolbar {
    func spokenSendHintBlocked() -> String {
        if isExecuting {
            return "escreva uma mensagem para adicionar à fila durante a execução"
        }
        if !model.drafts.isEmpty {
            return "adicione texto ou envie os anexos prontos"
        }
        return "escreva uma mensagem ou adicione um anexo para enviar"
    }
}

extension ComposerToolbar {
    func spokenSendHintReady() -> String {
        isExecuting
            ? "envia esta mensagem na fila do próximo turno"
            : "envia mensagem e anexos ao Atlas"
    }
}

extension AttachmentStrip {
    @ViewBuilder
    var attachmentDraftBranch: some View {
        if !drafts.isEmpty {
            DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                       onRemove: onRemove, onFailedTap: onFailedTap)
        }
    }
}

struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        if isVisible {
            Group {
                attachmentDraftBranch
                uploadProgressRow
            }
            .accessibilityIdentifier(A11yID.composerAttachmentStrip)
        }
    }
}

extension AttachmentStrip {
    func uploadPercentLabel(_ p: Double) -> some View {
        Text("\(Int(p * 100))%")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressBar(_ p: Double) -> some View {
        ProgressView(value: p).tint(AtlasTheme.accent)
    }
}

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            uploadProgressStack(p)
        }
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressA11y<Content: View>(_ content: Content, percent: Double) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("enviando anexos, \(Int(percent * 100)) por cento")
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressRow(_ p: Double) -> some View {
        HStack(spacing: 10) {
            uploadProgressBar(p)
            uploadPercentLabel(p)
        }
    }
}

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressStack(_ p: Double) -> some View {
        uploadProgressA11y(uploadProgressRow(p), percent: p)
    }
}

extension AttachmentStrip {
    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}

extension ComposerToolbar {
    @ViewBuilder var trailingOptionsMenu: some View {
        Menu {
            optionsMenuButtons
        } label: {
            Image(systemName: "ellipsis")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .accessibilityLabel("opções da conversa")
        .accessibilityHint(spokenOptionsHint())
        .accessibilityIdentifier(A11yID.conversationOptions)
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var optionsMenuButtons: some View {
        optionsWorkspaceButton
        optionsModeButton
        optionsEffortButton
    }
}

extension ComposerToolbar {
    var optionsEffortButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowEffort()
        } label: {
            Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
        }
        .accessibilityLabel(spokenEffortLabel(model.effort))
        .accessibilityHint(spokenEffortHint())
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel("modo, \(mode)")
        .accessibilityHint("abre opções de modo para o próximo envio")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    var optionsWorkspaceButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowWorkspace()
        } label: {
            Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
        }
        .accessibilityLabel("workspace, \(model.workspaceName ?? "Atlas")")
        .accessibilityHint("abre o seletor de workspace da conversa")
        .accessibilityAddTraits(.isButton)
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var trailingControlBranch: some View {
        if canSubmit {
            trailingSendButton
        } else if isExecuting {
            trailingProcessing
        } else {
            trailingOptionsMenu
        }
    }
}

extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        trailingControlBranch
    }
}

extension ComposerToolbar {
    var trailingProcessing: some View {
        ZStack {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.38))
                .accessibilityHidden(true)
        }
        .frame(width: 44, height: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
        .accessibilityHint(spokenSendHint(canSubmit: false))
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

extension ComposerToolbar {
    var trailingSendButton: some View {
        Button {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSend()
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityLabel(spokenSendLabel(canSubmit: true))
        .accessibilityHint(spokenSendHint(canSubmit: true))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(10) // primary commit surfaces first in VO
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}
