import SwiftUI
import AtlasCore

// Chrome extraído de ConversationView (Elite compressão).
extension ConversationView {
    // MARK: - Header

    var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title).font(AtlasFont.serif(17, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            // Continuidade: a MESMA thread/sessão continua em outra superfície.
            // Só para conversa canônica; o "pronto" só aparece com o recibo.
            if model.threadId != nil {
                Menu {
                    Button { showOutline = true } label: {
                        Label("Índice da conversa", systemImage: "list.bullet.rectangle")
                    }
                    Button {
                        Task { await model.handoffToSurface(.desktop) }
                    } label: { Label("Continuar no Mac", systemImage: "desktopcomputer") }
                    Button {
                        Task { await model.handoffToSurface(.terminal) }
                    } label: { Label("Continuar no Terminal", systemImage: "terminal") }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
                }
                .accessibilityLabel("continuar esta conversa em outra superfície")
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

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
                    try? await Task.sleep(nanoseconds: 320_000_000)
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
                .transition(.move(edge: .top).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation(AtlasMotion.editorial) { model.toast = nil }
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
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(AtlasMotion.editorial) {
            focused = true
            model.toast = "mensagem no composer para novo turno"
        }
    }

    func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(AtlasMotion.editorial) { model.toast = "\(label) copiada" }
    }
}
