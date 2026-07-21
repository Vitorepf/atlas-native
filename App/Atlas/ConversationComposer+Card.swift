import SwiftUI
import AtlasCore

// Card surface + body structure — WAVE-006.

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }

    var composerCardSurface: some View {
        VStack(alignment: .leading, spacing: expanded ? 12 : 0) {
            liveExecutionSection
            queueChipSection
            // Grabber morto (teclado dispensa no scroll) — EmptyView removed.
            composerAttachmentStrip
            composerToolbarOnly
        }
        .padding(composerCardPadding)
        .background(composerSurface)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: expanded)
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.86), value: model.drafts)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(composerCardSpokenLabel)
        .accessibilityHint(ConversationComposerA11y.cardHint)
    }

    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }

    var composerCardSpokenLabel: String {
        ConversationComposerA11y.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }

    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }

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

    /// Foco = forma (cápsula → cartão), não borda dourada gritante.
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
