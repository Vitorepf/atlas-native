import AtlasCore
import SwiftUI

// Cycle 041 fuse → ComposerToolbar+Attachments.swift

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
                .frame(width: 32, height: 32)
                .contentShape(Circle())
        }
        .accessibilityLabel("opções da conversa")
        .accessibilityHint(spokenOptionsHint())
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
        .accessibilityHint(spokenEffortHint())
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
        .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
        .accessibilityHint(spokenSendHint(canSubmit: false))
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
        .accessibilityLabel(spokenSendLabel(canSubmit: true))
        .accessibilityHint(spokenSendHint(canSubmit: true))
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}
