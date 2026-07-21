import AtlasCore
import SwiftUI

// Cycle 041 fuse → WorkspaceView+List.swift

extension WorkspaceView {
    var header: some View {
        HStack(spacing: 12) {
            headerBackButton
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    var headerBackButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).atlasGlassCircle()
        }
        .accessibilityLabel("voltar")
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowLoop(_ t: AtlasAiThread, newBadgeSuppressed: Bool = false) -> some View {
        WorkspaceThreadLink(thread: t, reduceMotion: reduceMotion, newBadgeSuppressed: newBadgeSuppressed)
        threadRowSeparator(after: t)
    }
}

extension WorkspaceThreadsSection {
    @ViewBuilder
    func threadRowSeparator(after thread: AtlasAiThread) -> some View {
        if thread.id != threads.last?.id {
            Divider().overlay(AtlasTheme.separator)
                .padding(.leading, AtlasTheme.Space.screen + 36)
        }
    }
}

extension WorkspaceThreadsSection {
    /// Badge "novo" saturado (maioria de 6+ linhas) perde o poder de
    /// discriminar — silencia em bloco; a ordenação já diz recência.
    var newBadgeSaturated: Bool {
        threads.count >= 6
            && threads.lazy.filter(ConversationModel.hasNewerContent).count * 2 > threads.count
    }

    @ViewBuilder
    var threadRows: some View {
        let saturated = newBadgeSaturated
        ForEach(threads) { t in
            threadRowLoop(t, newBadgeSuppressed: saturated)
        }
    }
}

struct WorkspaceThreadsSection: View {
    let threads: [AtlasAiThread]
    let area: AtlasArea
    let screenTitle: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            captionHeader
            threadRows
        }
    }
}
