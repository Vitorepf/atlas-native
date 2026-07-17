import SwiftUI
import UIKit
import AtlasCore

// Chrome extraído de ConversationView (Elite compressão).
extension ConversationView {
    // MARK: - Cache seal

    @ViewBuilder var cacheAgeSeal: some View {
        if model.showingStaleCache, let capturedAt = model.cacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: false, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(.opacity)
        } else if readSealConfirming, let capturedAt = lastCacheCapturedAt {
            StaleReadSeal(capturedAt: capturedAt, confirming: true, reduceMotion: reduceMotion)
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 2)
                .padding(.bottom, 8)
                .transition(.opacity)
                .task {
                    if !reduceMotion { try? await Task.sleep(nanoseconds: 320_000_000) }
                    readSealConfirming = false
                }
        }
    }

    // MARK: - Toast editorial

    @ViewBuilder var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(ConversationViewA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.conversationToast)
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    clearToast()
                }
        }
    }

    @ViewBuilder var handoffReceipt: some View {
        if let handoff = model.latestSurfaceHandoff {
            ConversationHandoffReceipt(handoff: handoff)
        }
    }

    func editAndResend(_ bubble: ChatBubble) {
        guard bubble.role == "user" else { return }
        model.updateDraft(bubble.text)
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        focused = true
        setToast("mensagem no composer para novo turno")
    }

    func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        if !reduceMotion { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        setToast("\(label) copiada")
    }
}
