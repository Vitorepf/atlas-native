import SwiftUI
import AtlasCore

// Scroll de turnos + FAB de retorno ao fim — peel de ConversationView (régua <300).

struct ConversationMessages: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var emptyPrompt: String?
    var emptySuggestions: [String]?
    @Binding var awayFromBottom: Bool
    @Binding var lastScrollAt: CFAbsoluteTime
    @Binding var lastScrollBubbleCount: Int
    @Binding var reviewTrace: ConversationReviewTraceRef?
    @Binding var artifactTrace: ConversationReviewTraceRef?
    @Binding var steerTrace: ConversationSteerTraceRef?
    var onEditResend: (ChatBubble) -> Void
    var onCopy: (String, String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if model.bubbles.isEmpty {
                    EmptyConversation(
                        reduceMotion: reduceMotion,
                        prompt: emptyPrompt,
                        suggestions: emptySuggestions
                    ) { suggestion in
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        let effort = model.effort
                        Task { await model.send(suggestion, effort: effort) }
                    }
                } else {
                    LazyVStack(alignment: .leading, spacing: 40) {
                        ForEach(model.bubbles) { bubble in
                            if bubble.id == model.firstNewBubbleId {
                                NewSinceLastVisitMarker()
                                    .id("new-since-last-visit")
                            }
                            let traceArtifacts = bubble.traceId.flatMap { model.reviews.artifactsByTrace[$0] }
                            let artifactItems = traceArtifacts?.state == .available ? traceArtifacts?.items ?? [] : []
                            EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                                          onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                                          onCopy: { onCopy(bubble.text, bubble.role == "user" ? "mensagem" : "resposta") },
                                          onEditResend: { onEditResend(bubble) },
                                          onStop: { model.cancel() },
                                          onExecutionChoice: { jobId, optionId in
                                              Task { await model.resolveExecutionChoice(jobId: jobId, optionId: optionId) }
                                          },
                                          onRetry: { jobId in
                                              Task { await model.retryTurn(jobId: jobId) }
                                          },
                                          onSteer: { trace in steerTrace = ConversationSteerTraceRef(id: trace) },
                                          artifactItems: artifactItems,
                                          onOpenArtifacts: { trace in artifactTrace = ConversationReviewTraceRef(id: trace) })
                            .equatable()
                            .id(bubble.id)
                            .task(id: bubble.traceId?.rawValue) {
                                if bubble.role == "assistant", !bubble.streaming, let trace = bubble.traceId {
                                    await model.reviews.refreshArtifacts(traceId: trace)
                                }
                            }
                            // C15: revisão só entra pela projeção canônica do
                            // trace (a folha diz "sem artefatos" quando não há).
                            if bubble.role == "assistant", !bubble.streaming,
                               !bubble.activities.isEmpty, let trace = bubble.traceId {
                                Button { reviewTrace = ConversationReviewTraceRef(id: trace) } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.forwardslash.minus").font(.system(size: 11))
                                        Text("Revisar mudanças").font(.system(.footnote, weight: .medium))
                                    }
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                    .padding(.horizontal, 13).padding(.vertical, 7)
                                    .background(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
                                }
                                .buttonStyle(PressableScale())
                                .accessibilityHint("abre arquivos, diff e provas desta execução")
                            }
                        }
                        Color.clear.frame(height: 96).id("bottom")
                            .background(GeometryReader { geo in
                                Color.clear.preference(key: BottomDistanceKey.self,
                                                       value: geo.frame(in: .global).minY)
                            })
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 16)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onPreferenceChange(BottomDistanceKey.self) { minY in
                // marcador abaixo da dobra + margem → operador navegou pra cima
                awayFromBottom = minY > UIScreen.main.bounds.height + 140
            }
            .overlay(alignment: .bottomTrailing) {
                if awayFromBottom {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.25)) {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(AtlasTheme.surfaceHi)
                                .overlay(Circle().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 2))
                    }
                    .buttonStyle(PressableScale())
                    .padding(.trailing, AtlasTheme.Space.screen).padding(.bottom, 110)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .accessibilityLabel("ir para o fim da conversa")
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: awayFromBottom)
            .onChange(of: model.bubbles) {
                let count = model.bubbles.count
                let now = CFAbsoluteTimeGetCurrent()
                let countChanged = count != lastScrollBubbleCount
                guard countChanged || now - lastScrollAt >= 0.1 else { return }
                lastScrollAt = now
                lastScrollBubbleCount = count
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

// Distância do marcador de fim da conversa ao topo global (FAB de retorno).
private struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
