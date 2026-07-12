import SwiftUI
import AtlasCore

// A tela de conversa — o coração do Atlas AI no app. Bolhas no estilo Cursor
// (usuário à direita, assistente como texto corrido à esquerda), STREAMING ao
// vivo token a token, e o input funcional. Motor: ConversationModel/AtlasCore.
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var model: ConversationModel
    @State private var draft = ""
    @FocusState private var focused: Bool

    init(client: AtlasClient, threadId: String?, title: String) {
        self.title = title
        _model = State(initialValue: ConversationModel(client: client, threadId: threadId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                messages
            }

            inputBar
        }
        .navigationBarHidden(true)
        .task { await model.load() }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title)
                .font(AtlasFont.serif(17, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
            Spacer()
            Color.clear.frame(width: 40, height: 40)   // simetria
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 6)
    }

    // MARK: - Messages

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if model.bubbles.isEmpty {
                    emptyPrompt
                } else {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(model.bubbles) { BubbleView(bubble: $0) }
                        Color.clear.frame(height: 88).id("bottom")
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 12)
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: model.bubbles) {
                withAnimation(.easeOut(duration: 0.15)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private var emptyPrompt: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkle")
                .font(.system(size: 26))
                .foregroundStyle(AtlasTheme.accent)
            Text("O que você quer pensar agora?")
                .font(AtlasFont.serifItalic(21))
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 120)
        .padding(.horizontal, 40)
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 30, height: 30)
                .background(Circle().fill(AtlasTheme.surfaceHi))

            TextField("", text: $draft, prompt: Text("Escreva ao Atlas").foregroundColor(AtlasTheme.textTertiary), axis: .vertical)
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1...5)
                .focused($focused)
                .onSubmit(send)

            let canSend = !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !model.isSending
            Button(action: send) {
                Image(systemName: canSend ? "arrow.up.circle.fill" : "mic.fill")
                    .font(.system(size: canSend ? 26 : 17))
                    .foregroundStyle(canSend ? AtlasTheme.accent : AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        )
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 28)
        .padding(.bottom, 6)
        .background(
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private func send() {
        let text = draft
        draft = ""
        Task { await model.send(text) }
    }
}

// MARK: - Bolha

private struct BubbleView: View {
    let bubble: ChatBubble

    var body: some View {
        if bubble.role == "user" {
            HStack {
                Spacer(minLength: 40)
                Text(bubble.text)
                    .font(.system(size: 16))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surfaceHi))
            }
        } else {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "sparkle")
                    .font(.system(size: 14))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.top, 3)
                if bubble.text.isEmpty && bubble.streaming {
                    Text("pensando…")
                        .font(.system(size: 16))
                        .foregroundStyle(AtlasTheme.textTertiary)
                } else {
                    Text(bubble.text + (bubble.streaming ? " ▍" : ""))
                        .font(.system(size: 16))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
