import SwiftUI
import AtlasCore

// IDLE-COMPRESS fused

// --- NightlyProposalCard+A11yShell.swift ---
extension NightlyProposalCard {
    var cardA11y: some View {
        cardChrome
            // .contain preserva botões Preparar/hoje não; o id do card fica
            // no contentor sem engolir os CTAs (XCUITest + VoiceOver).
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.nightlyProposalCard)
    }
}

// --- NightlyProposalCard+Actions.swift ---
extension NightlyProposalCard {
    var actionRow: some View {
        HStack(spacing: 10) {
            Button("Preparar missão noturna") {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onAccept()
            }
            .buttonStyle(AutonomosPrimaryButtonStyle())
            .accessibilityIdentifier(A11yID.nightlyProposalAccept)
            .accessibilityLabel(Self.spokenAcceptLabel())
            .accessibilityHint(Self.spokenAcceptHint())
            dismissButton
            muteMenu
        }
    }
}

// --- NightlyProposalCard+Chrome.swift ---
extension NightlyProposalCard {
    var cardChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: AtlasTheme.Radius.card)
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}

// --- NightlyProposalCard+Copy.swift ---
extension NightlyProposalCard {
    var masthead: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Text(learnedDayEnd.map { "MISSÃO NOTURNA · NO SEU RITMO (~\($0))" }
                ?? "MISSÃO NOTURNA · NO SEU RITMO")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

// --- NightlyProposalCard+CopyBody.swift ---
extension NightlyProposalCard {
    var copyBlock: some View {
        Group {
            Text("Hoje você trabalhou em \(proposal.workspaceText).")
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Text("A frota pode continuar enquanto você descansa.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

// --- NightlyProposalCard+Dismiss.swift ---
extension NightlyProposalCard {
    var dismissButton: some View {
        Button("hoje não") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onDismiss()
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.nightlyProposalDismiss)
        .accessibilityLabel(Self.spokenDismissLabel())
        .accessibilityHint(Self.spokenDismissHint())
    }
}

// --- NightlyProposalCard+Mute.swift ---
extension NightlyProposalCard {
    var muteMenu: some View {
        Menu("pausar") {
            ForEach(Self.muteDays, id: \.self) { days in
                Button("\(days) dia\(days == 1 ? "" : "s")") {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onMute(days)
                }
                .accessibilityLabel(Self.spokenMuteOption(days: days))
                .accessibilityHint(Self.spokenMuteOptionHint())
            }
        }
        .font(AtlasFont.mono(11, .semibold))
        .foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityIdentifier(A11yID.nightlyProposalMute)
        .accessibilityLabel(Self.spokenMuteMenuLabel())
        .accessibilityHint(Self.spokenMuteMenuHint())
    }
}

