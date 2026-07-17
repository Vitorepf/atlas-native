import SwiftUI
import PhotosUI
import AtlasCore

// Composer da conversa — peel de ConversationView (régua anti-inchaço).
// Superfície de escrita + strip de anexos + fila + execução viva + folhas.
// Callbacks e A11yIDs idênticos; zero mudança de rota.

struct ConversationComposer: View {
    var model: ConversationModel
    var session: AtlasSession
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding

    @Binding var mode: String
    @Binding var showModeSheet: Bool
    @Binding var showWorkspaceSheet: Bool
    @Binding var showQueueSheet: Bool
    @Binding var showAttachmentSheet: Bool
    @Binding var pickedPhoto: PhotosPickerItem?
    @Binding var showFileImporter: Bool
    @Binding var showCamera: Bool
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?

    // Anexo presente = card aberto: sem isso, anexar com o composer colapsado
    // deixava o operador sem botão de enviar (a fileira de controles só existia
    // com o teclado aberto). Estado de composição ⊃ estado de foco.
    private var expanded: Bool { focused.wrappedValue || !model.drafts.isEmpty }

    /// Turno vivo (streaming) — dirige a faixa de execução dentro do composer.
    private var liveBubble: ChatBubble? { model.bubbles.last(where: { $0.streaming }) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            composerCard
        }
        .animation(.easeOut(duration: 0.25), value: model.isSending)
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var composerCard: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            // Execução em curso: UMA linha discreta dentro do próprio card —
            // nunca um segundo elemento empilhado. O campo continua aberto:
            // escrever durante a execução é direito do operador.
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
                Rectangle().fill(AtlasTheme.separatorSoft).frame(height: 1)
                    .padding(.bottom, expanded ? 0 : 8)
            }
            // C11: mensagens mandadas durante a execução viram FILA (o model
            // enfileira sozinho). O chip só existe quando a fila existe —
            // nada inventado; tocar abre a folha com enviar-agora e remover.
            if !model.queuedMessages.isEmpty {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showQueueSheet = true
                } label: {
                    Text("Fila \(model.queuedMessages.count)")
                        .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.accent)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                }
                .buttonStyle(PressableScale())
                .padding(.bottom, expanded ? 0 : 8)
                .transition(.opacity)
                .accessibilityLabel("\(model.queuedMessages.count) mensagens na fila, toque para gerenciar")
            }
            if focused.wrappedValue {
                // Grabber → PUXE pra baixo (ou toque) para fechar o teclado.
                // Área de toque generosa (padding antes do contentShape) + drag.
                RoundedRectangle(cornerRadius: 3)
                    .fill(AtlasTheme.textTertiary.opacity(0.55))
                    .frame(width: 42, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .contentShape(Rectangle())
                    .onTapGesture { dismissKeyboard() }
                    .gesture(
                        DragGesture(minimumDistance: 6)
                            .onEnded { if $0.translation.height > 8 { dismissKeyboard() } }
                    )
                    .accessibilityLabel("fechar teclado")
                    .accessibilityAddTraits(.isButton)
            }
            // Strip de anexos (o contrato de UI é o LocalDraft, nada mais)
            if !model.drafts.isEmpty {
                DraftStrip(drafts: model.drafts, reduceMotion: reduceMotion,
                           onRemove: { model.removeDraft($0) },
                           onFailedTap: { model.toast = $0 })
            }
            if let p = model.uploadPercent {
                HStack(spacing: 10) {
                    ProgressView(value: p).tint(AtlasTheme.accent)
                    Text("\(Int(p * 100))%")
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
            }

            HStack(spacing: 10) {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showAttachmentSheet = true
                } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(PressableScale())
                .accessibilityLabel("adicionar anexo")
                ZStack(alignment: .topLeading) {
                    Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                        .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
                        .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
                        .animation(.easeOut(duration: 0.28), value: model.draftText.isEmpty)
                    TextField("", text: Binding(
                        get: { model.draftText },
                        set: { model.updateDraft($0) }
                    ), axis: .vertical)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).lineLimit(1...6).focused(focused)
                        .accessibilityIdentifier(A11yID.conversationInput)
                }
                composerTrailingControl
            }
        }
        .padding(expanded ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
                          : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
        .background(composerSurface)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(.spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .conversationComposerSheets(
            model: model,
            session: session,
            mode: $mode,
            showModeSheet: $showModeSheet,
            showWorkspaceSheet: $showWorkspaceSheet,
            showQueueSheet: $showQueueSheet,
            showAttachmentSheet: $showAttachmentSheet,
            showCamera: $showCamera,
            showFileImporter: $showFileImporter,
            pickedPhoto: $pickedPhoto,
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace,
            steerReceipt: steerReceipt(for:),
            onSteerSubmit: submitSteer
        )
    }

    @ViewBuilder private var composerSurface: some View {
        if expanded || liveBubble != nil {
            // Com execução viva o card cresce em cartão (capsule de 2 linhas
            // deformaria); a borda dourada continua reservada ao foco.
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(expanded ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }

    private var composerCanSubmit: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if model.isSending || liveBubble != nil {
            return hasText
        }
        return hasText || !model.drafts.isEmpty
    }

    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder private var composerTrailingControl: some View {
        if composerCanSubmit {
            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel(model.isSending ? "adicionar à fila" : "enviar ao Atlas")
        } else if model.isSending {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .frame(width: 32, height: 32)
                .accessibilityLabel("Atlas processando")
        } else {
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showWorkspaceSheet = true
                } label: {
                    Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    showModeSheet = true
                } label: {
                    Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
                }
                Button {
                    model.cycleEffort()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .accessibilityLabel("opções da conversa")
        }
    }

    private func dismissKeyboard() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
    }

    private func send() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

    private func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }

    private func steerReceipt(for traceId: TraceID) -> AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }

    private func steerReceiptText(_ receipt: AtlasInteractionSteerResponse) -> String {
        receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"
    }
}
