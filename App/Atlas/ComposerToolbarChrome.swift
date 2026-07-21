import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

// --- ComposerToolbar+A11y.swift ---
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

// --- ComposerToolbar+A11yHint.swift ---
extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        canSubmit ? spokenSendHintReady() : spokenSendHintBlocked()
    }
}

// --- ComposerToolbar+A11yInput+Effort+Light.swift ---
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

// --- ComposerToolbar+A11yInput+Effort.swift ---
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

// --- ComposerToolbar+A11yInput+Hints.swift ---
extension ComposerToolbar {
    func spokenEffortHint() -> String {
        "abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "modo, esforço e workspace; \(spokenSendHint(canSubmit: false).lowercased())"
    }
}

// --- ComposerToolbar+A11yInput.swift ---


// --- ComposerToolbar+A11yInputField.swift ---
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

// --- ComposerToolbar+A11yProcessingLabel.swift ---
extension ComposerToolbar {
    func spokenProcessingLabel() -> String { "Atlas processando" }
}

// --- ComposerToolbar+A11ySendHintBlocked.swift ---
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

// --- ComposerToolbar+A11ySendHintReady.swift ---
extension ComposerToolbar {
    func spokenSendHintReady() -> String {
        isExecuting
            ? "envia esta mensagem na fila do próximo turno"
            : "envia mensagem e anexos ao Atlas"
    }
}

// --- ComposerToolbar+AttachmentStrip+DraftBranch.swift ---
extension AttachmentStrip {
    @ViewBuilder
    var attachmentDraftBranch: some View {
        if !drafts.isEmpty {
            DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                       onRemove: onRemove, onFailedTap: onFailedTap)
        }
    }
}

// --- ComposerToolbar+AttachmentStrip.swift ---
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

// --- ComposerToolbar+AttachmentStripUpload+PercentLabel.swift ---
extension AttachmentStrip {
    func uploadPercentLabel(_ p: Double) -> some View {
        Text("\(Int(p * 100))%")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }
}

// --- ComposerToolbar+AttachmentStripUpload+ProgressBar.swift ---
extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressBar(_ p: Double) -> some View {
        ProgressView(value: p).tint(AtlasTheme.accent)
    }
}

// --- ComposerToolbar+AttachmentStripUpload+ProgressRow.swift ---
extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            uploadProgressStack(p)
        }
    }
}

// --- ComposerToolbar+AttachmentStripUpload+ProgressStack+A11y.swift ---
extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressA11y<Content: View>(_ content: Content, percent: Double) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("enviando anexos, \(Int(percent * 100)) por cento")
    }
}

// --- ComposerToolbar+AttachmentStripUpload+ProgressStack+Row.swift ---
extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressRow(_ p: Double) -> some View {
        HStack(spacing: 10) {
            uploadProgressBar(p)
            uploadPercentLabel(p)
        }
    }
}

// --- ComposerToolbar+AttachmentStripUpload+ProgressStack.swift ---
extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressStack(_ p: Double) -> some View {
        uploadProgressA11y(uploadProgressRow(p), percent: p)
    }
}

// --- ComposerToolbar+AttachmentStripUpload+Visibility.swift ---
extension AttachmentStrip {
    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}

// --- ComposerToolbar+CanSubmit+DraftEmpty.swift ---
extension ComposerToolbar {
    var canSubmitFromDraft: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || !model.drafts.isEmpty
    }
}

// --- ComposerToolbar+CanSubmit+Sending.swift ---
extension ComposerToolbar {
    var canSubmitWhileSending: Bool {
        !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// --- ComposerToolbar+CanSubmit.swift ---
extension ComposerToolbar {
    var canSubmit: Bool {
        if model.isSending || liveBubble != nil {
            return canSubmitWhileSending
        }
        return canSubmitFromDraft
    }
}

// --- ComposerToolbar+Field+Placeholder.swift ---
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

// --- ComposerToolbar+Field+TextFieldInput.swift ---
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

// --- ComposerToolbar+Field.swift ---
extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            composerFieldPlaceholder
            composerTextFieldInput
        }
    }
}

// --- ComposerToolbar+FieldAttach.swift ---
extension ComposerToolbar {
    var attachButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAttach()
        } label: {
            Image(systemName: "paperclip")
                .atlasSans(17, .medium)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("adicionar anexo")
        .accessibilityHint("abre foto, arquivo ou colar")
    }
}

// --- ComposerToolbar+Options.swift ---
extension ComposerToolbar {
    @ViewBuilder var trailingOptionsMenu: some View {
        Menu {
            optionsMenuButtons
        } label: {
            Image(systemName: "ellipsis")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .accessibilityLabel("opções da conversa")
        .accessibilityHint(spokenOptionsHint())
        .accessibilityIdentifier(A11yID.conversationOptions)
    }
}

// --- ComposerToolbar+OptionsButtons.swift ---
extension ComposerToolbar {
    @ViewBuilder
    var optionsMenuButtons: some View {
        optionsWorkspaceButton
        optionsModeButton
        optionsEffortButton
    }
}

// --- ComposerToolbar+OptionsEffort.swift ---
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
    }
}

// --- ComposerToolbar+OptionsItems.swift ---


// --- ComposerToolbar+OptionsMode.swift ---
extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel("modo, \(mode)")
    }
}

// --- ComposerToolbar+OptionsWorkspace.swift ---
extension ComposerToolbar {
    var optionsWorkspaceButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowWorkspace()
        } label: {
            Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
        }
        .accessibilityLabel("workspace, \(model.workspaceName ?? "Atlas")")
    }
}

// --- ComposerToolbar+Row+Attach.swift ---
extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowAttach: some View {
        attachButton
    }
}

// --- ComposerToolbar+Row+Field.swift ---
extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowField: some View {
        composerTextField
    }
}

// --- ComposerToolbar+Row+Trailing.swift ---
extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowTrailing: some View {
        trailingControl
    }
}

// --- ComposerToolbar+Row.swift ---
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

// --- ComposerToolbar+Trailing+Branch.swift ---
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

// --- ComposerToolbar+Trailing.swift ---
extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        trailingControlBranch
    }
}

// --- ComposerToolbar+TrailingProcessing.swift ---
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
        .frame(width: 32, height: 32)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
        .accessibilityHint(spokenSendHint(canSubmit: false))
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

// --- ComposerToolbar+TrailingSend.swift ---
extension ComposerToolbar {
    var trailingSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityLabel(spokenSendLabel(canSubmit: true))
        .accessibilityHint(spokenSendHint(canSubmit: true))
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

