import AtlasCore
import SwiftUI

// Cycle 041 fuse → ConversationComposer+Queue.swift

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
            .background(Capsule().fill(AtlasTheme.goldVeil)
                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
    }
}

extension ConversationComposer {
    var keyboardGrabberBar: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(AtlasTheme.textTertiary.opacity(0.55))
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
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
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
