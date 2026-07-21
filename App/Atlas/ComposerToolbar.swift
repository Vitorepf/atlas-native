import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: ComposerToolbar fused

// MARK: - ComposerToolbar

// MARK: - Host

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

// MARK: - Chrome

extension ComposerToolbar {
    var isExecuting: Bool { model.isSending || liveBubble != nil }

    /// WAVE-046: exclusive send readiness face.
    var sendFace: ComposerSendFace {
        ComposerSendJudgment.face(
            draftText: model.draftText,
            drafts: model.drafts,
            isSending: model.isSending,
            liveBubblePresent: liveBubble != nil
        )
    }

    func spokenSendLabel(canSubmit: Bool) -> String {
        // Prefer face grammar; keep canSubmit for call sites still passing bool.
        if canSubmit != sendFace.allowsSend {
            return sendFace.spokenLabel
        }
        return sendFace.spokenLabel
    }
}

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        _ = canSubmit
        return sendFace.spokenHint
    }
}

extension ComposerToolbar {
    /// WAVE-076: exclusive effort face from published model.effort.
    var effortFace: ComposerEffortFace {
        ComposerEffortJudgment.face(model.effort)
    }

    func spokenEffortLabel(_ effort: AtlasComputeEffort) -> String {
        ComposerEffortJudgment.spokenToolbar(effort)
    }

    func spokenEffortHint() -> String {
        ComposerEffortJudgment.effortHint
    }

    func spokenOptionsHint() -> String {
        ComposerEffortJudgment.spokenOptionsHint(
            sendHint: spokenSendHint(canSubmit: false)
        )
    }
}

extension ComposerToolbar {
    func spokenInputLabel() -> String {
        ComposerEffortJudgment.spokenInputLabel(bubblesEmpty: model.bubbles.isEmpty)
    }

    func spokenInputHint() -> String {
        ComposerEffortJudgment.spokenInputHint(
            canSubmit: canSubmit,
            isExecuting: isExecuting
        )
    }
}

extension ComposerToolbar {
    func spokenProcessingLabel() -> String {
        ComposerEffortJudgment.processingLabel
    }
}

extension ComposerToolbar {
    func spokenSendHintBlocked() -> String { sendFace.spokenHint }

    func spokenSendHintReady() -> String { sendFace.spokenHint }
}

extension AttachmentStrip {
    /// WAVE-086: exclusive strip face from draft + upload percent.
    var stripFace: ComposerDraftStripFace {
        ComposerDraftJudgment.stripFace(drafts: drafts, uploadPercent: uploadPercent)
    }

    @ViewBuilder
    var attachmentDraftBranch: some View {
        if !drafts.isEmpty {
            DraftStrip(
                drafts: drafts,
                reduceMotion: reduceMotion,
                onRemove: onRemove,
                onFailedTap: onFailedTap,
                uploadPercent: uploadPercent
            )
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
            .accessibilityValue(stripFace.productWord)
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
            .accessibilityLabel(ComposerDraftJudgment.spokenUploadPercent(percent))
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

// MARK: - Chrome body / sections

// MARK: - Attachment strip
extension AttachmentStrip {
    var isVisible: Bool {
        ComposerDraftJudgment.isStripVisible(drafts: drafts, uploadPercent: uploadPercent)
    }
}

extension ComposerToolbar {
    /// WAVE-046: gold/queue only when face allows — never with failed/uploading drafts.
// MARK: - Send readiness
    var canSubmit: Bool { sendFace.allowsSend }
}

// MARK: - Field
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

// MARK: - Attach / options
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
        .accessibilityLabel(ComposerToolbarJudgment.spokenAttach())
        .accessibilityHint(ComposerToolbarJudgment.spokenAttachHint())
    }
}

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
        .accessibilityLabel(ComposerToolbarJudgment.spokenOptions())
        .accessibilityHint(
            ComposerToolbarJudgment.spokenOptionsHint(effortOptionsHint: spokenOptionsHint())
        )
        .accessibilityIdentifier(A11yID.conversationOptions)
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
        .accessibilityValue(effortFace.productWord)
        .accessibilityHint(spokenEffortHint())
    }
}

extension ComposerToolbar {
    var optionsModeButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowMode()
        } label: {
            Label(ComposerToolbarJudgment.modeMenuTitle(mode), systemImage: "slider.horizontal.3")
        }
        .accessibilityLabel(ComposerToolbarJudgment.spokenMode(mode))
    }
}

extension ComposerToolbar {
    var optionsWorkspaceButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onShowWorkspace()
        } label: {
            Label(
                ComposerToolbarJudgment.workspaceMenuTitle(model.workspaceName),
                systemImage: "square.grid.2x2"
            )
        }
        .accessibilityLabel(ComposerToolbarJudgment.spokenWorkspace(model.workspaceName))
    }
}

// MARK: - Toolbar row layout
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
        .frame(width: 32, height: 32)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ComposerSendJudgment.spokenSendChrome(processing: spokenProcessingLabel(), sendSpoken: sendFace.spokenLabel))
        .accessibilityHint(sendFace.spokenHint)
        .accessibilityValue(sendFace.productWord)
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

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
        .accessibilityLabel(sendFace.spokenLabel)
        .accessibilityHint(sendFace.spokenHint)
        .accessibilityValue(sendFace.productWord)
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}

