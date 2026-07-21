import SwiftUI
import AtlasCore

// WAVE-123 ComposerToolbar chrome peel B

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

