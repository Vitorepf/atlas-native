import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

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

