import AtlasCore
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers
import Foundation

// Cycle 044 fuse → ConversationSheets.swift

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
            .accessibilityLabel(CameraPickerA11y.spokenSurface)
            .accessibilityHint(CameraPickerA11y.spokenHint)
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
        model.toast = CameraPickerA11y.captureFailedToast
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

struct ConversationComposerSheetsModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                AtlasMotion.successNotification(reduceMotion: reduceMotion)
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


// Cycle 043 fuse → SteerInteractionSheet.swift

struct SteerInteractionSheet: View {
    let traceId: TraceID
    var model: ConversationModel
    let onSubmit: (String, AtlasInteractionSteerScope) -> Void

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var instruction = ""
    @State var scope: AtlasInteractionSteerScope = .currentStep

    var body: some View {
        steerA11yShell(steerNavigationStack)
    }
}

extension SteerInteractionSheet {
    var formHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Redirecionar")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("A instrução entra no próximo checkpoint seguro desta execução. O Atlas pode recusar e devolver o motivo público.")
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            formScopePicker
        }
    }
}

// Recibo só de model.lastSteerReceipt; silêncio total sem recibo correspondente.

extension SteerInteractionSheet {
    func spokenReceiptLabel(_ receipt: AtlasInteractionSteerResponse) -> String {
        if receipt.isAccepted {
            return "último recibo, instrução enfileirada para o próximo checkpoint seguro"
        }
        let reason = receipt.reason?.rawValue ?? "motivo_indisponivel"
        return "último recibo, steering rejeitado, motivo \(reason)"
    }
}

extension SteerInteractionSheet {
    func spokenScopeLabel(_ scope: AtlasInteractionSteerScope) -> String {
        switch scope {
        case .currentStep: return "escopo passo atual"
        case .replan: return "escopo replanejamento"
        }
    }
}

extension SteerInteractionSheet {
    func spokenSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "enviar instrução de redirecionamento" : "enviar indisponível, instrução vazia"
    }
}

extension SteerInteractionSheet {
    func spokenSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia a instrução ao Atlas no escopo selecionado"
            : "escreva o que muda a partir daqui"
    }
}

extension SteerInteractionSheet {
    func steerA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.steerSheet)
            // Contain without fused sheet label so scope/field/submit stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension SteerInteractionSheet {
    var formContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            formHeader
            instructionField
            formReceiptLine
            Spacer(minLength: 0)
        }
        .padding(22)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: matchedReceipt)
    }
}

extension SteerInteractionSheet {
    var formScopePicker: some View {
        Picker("Escopo", selection: $scope) {
            ForEach(AtlasInteractionSteerScope.allCases, id: \.self) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
        .frame(minHeight: 44) // HIG interactive minimum
        .onChange(of: scope) { _, _ in
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
        }
        .accessibilityIdentifier(A11yID.steerScope)
        .accessibilityLabel(spokenScopeLabel(scope))
        .accessibilityHint("define se a instrução vale o passo atual ou um replanejamento")
    }
}

extension SteerInteractionSheet {
    @ViewBuilder
    var formReceiptLine: some View {
        if let receipt = matchedReceipt {
            receiptLine(receipt)
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityIdentifier(A11yID.steerReceipt)
                .accessibilityLabel(spokenReceiptLabel(receipt))
        }
    }
}

extension SteerInteractionSheet {
    var instructionField: some View {
        TextField("O que muda a partir daqui?", text: $instruction, axis: .vertical)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent)
            .lineLimit(3...7)
            .padding(12)
            .frame(minHeight: 88, alignment: .topLeading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityIdentifier(A11yID.steerInstruction)
            .accessibilityHint("descreve o que deve mudar na execução")
    }
}

extension SteerInteractionSheet {
    var steerNavigationStack: some View {
        NavigationStack {
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                formContent
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { steerToolbar }
        }
    }
}

extension SteerInteractionSheet {
    var canSubmit: Bool {
        !instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var matchedReceipt: AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerToolbar: some ToolbarContent {
        steerCancelItem
        steerSubmitItem
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerCancelItem: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            AtlasCloseToolbarButton(
                title: "Cancelar",
                spokenLabel: "cancelar redirecionamento",
                spokenHint: "fecha sem enviar instrução",
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension SteerInteractionSheet {
    @ToolbarContentBuilder
    var steerSubmitItem: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            steerSubmitButton
        }
    }
}

extension SteerInteractionSheet {
    var steerSubmitButton: some View {
        Button("Enviar") {
            // Medium: primary governed redirect (same class as composer send).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onSubmit(instruction, scope)
        }
        .disabled(!canSubmit)
        .accessibilityIdentifier(A11yID.steerSubmit)
        .accessibilityLabel(spokenSubmitLabel(canSubmit: canSubmit))
        .accessibilityHint(spokenSubmitHint(canSubmit: canSubmit))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(canSubmit ? 9 : 0)
    }
}

extension SteerInteractionSheet {
    func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        let text = receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"

        return Text(text)
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.surface.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}


// Cycle 043 fuse → QueuedFollowUpsSheet.swift

/// Folha C11: mensagens enfileiradas durante execução — promover (enviar agora)
/// ou remover. Só renderiza o que `ConversationModel.queuedMessages` expõe.
struct QueuedFollowUpsSheet: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dismiss) var dismiss

    var model: ConversationModel

    var body: some View {
        queueSheetA11yShell(queueSheetBodyBranch)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueMessageRows(messages: [QueuedMessage]) -> some View {
        let total = messages.count
        ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
            QueuedFollowUpRow(
                message: message,
                index: index,
                total: total,
                onPromote: { Task { await model.promote(id: message.id) } },
                onRemove: { Task { await model.removeQueued(id: message.id) } }
            )
            .transition(reduceMotion ? .identity : .opacity)
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: messages.map(\.id))
    }
}

extension QueuedFollowUpsSheet {
    var sheetContent: some View {
        let messages = model.queuedMessages
        let total = messages.count
        return SheetShell(title: sheetTitle(count: total)) {
            queueOrderCaption(total: total)
            queueMessageRows(messages: messages)
        }
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("ordem da fila · a cabeça envia quando o turno terminar")
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(
                    "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                )
        }
    }
}

extension QueuedFollowUpsSheet {
    func queueSheetA11yShell<V: View>(_ content: V) -> some View {
        content
            .accessibilityIdentifier(A11yID.queueSheet)
            // Contain without fused sheet label so queue rows stay focusable.
            .accessibilityElement(children: .contain)
    }
}

extension QueuedFollowUpsSheet {
    @ViewBuilder
    var queueSheetBodyBranch: some View {
        if model.queuedMessages.isEmpty {
            emptyQueueDismiss
        } else {
            sheetContent
        }
    }
}

extension QueuedFollowUpsSheet {
    var emptyQueueDismiss: some View {
        Color.clear.onAppear { dismiss() }
    }
}

extension QueuedFollowUpsSheet {
    func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }
}


// Cycle 043 fuse → QueuedFollowUpRow.swift

struct QueuedFollowUpRow: View {
    let message: QueuedMessage
    let index: Int
    let total: Int
    let onPromote: () -> Void
    let onRemove: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        rowLayout
    }
}

extension QueuedFollowUpRow {
    var promoteLabel: String { "enviar agora, \(positionCaption): \(message.text)" }
    var promoteHint: String { "torna esta mensagem a próxima instrução; o turno atual continua" }
    var removeLabel: String { "remover da fila, \(positionCaption): \(message.text)" }
    var removeHint: String { "remove da fila sem enviar" }
}

extension QueuedFollowUpRow {
    var positionCaption: String {
        let ordinal = index + 1
        if ordinal == 1 { return "próxima na fila" }
        return "\(ordinal)ª na fila"
    }

    var rowSpokenLabel: String {
        let ordinal = index + 1
        if total == 1 { return message.text }
        if ordinal == 1 { return "primeira na fila, \(total) no total. \(message.text)" }
        return "\(ordinal)ª de \(total) na fila. \(message.text)"
    }
}

extension QueuedFollowUpRow {
    var promoteButton: some View {
        Button {
            // Medium: promote commits the next instruction (send class).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onPromote()
        } label: {
            Image(systemName: "arrow.up")
                .atlasSans(15, .semibold)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AtlasTheme.goldVeil))
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(promoteLabel)
        .accessibilityHint(promoteHint)
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // promote is send-class
        .accessibilityIdentifier(A11yID.queuePromote(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            rowText
            promoteButton
            removeButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .frame(minHeight: 56, alignment: .center)
        .contentShape(Rectangle())
        .accessibilityIdentifier(A11yID.queueRow(index))
        .overlay(alignment: .bottom) {
            Divider().overlay(AtlasTheme.separator).padding(.leading, 24)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var removeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRemove()
        } label: {
            Image(systemName: "trash")
                .atlasSans(14)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(AtlasTheme.surfaceHi))
                .contentShape(Circle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(removeLabel)
        .accessibilityHint(removeHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.queueRemove(message.id))
    }
}

extension QueuedFollowUpRow {
    var rowMessagePreview: some View {
        Text(message.text)
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}

extension QueuedFollowUpRow {
    @ViewBuilder
    var rowPositionCaption: some View {
        if total > 1 {
            Text(positionCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(index == 0 ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension QueuedFollowUpRow {
    var rowText: some View {
        VStack(alignment: .leading, spacing: 4) {
            rowPositionCaption
            rowMessagePreview
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowSpokenLabel)
    }
}
