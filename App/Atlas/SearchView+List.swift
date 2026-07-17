import SwiftUI
import AtlasCore

// Peel anti-inchaço — lista, resultados e miss honesto do SearchView.
// ThreadLink → SearchView+ThreadLink.swift

struct SearchRecentSection: View {
    let threads: [AtlasAiThread]
    let reduceMotion: Bool

    var body: some View {
        Group {
            Text("RECENTES")
                .font(.system(.caption, weight: .semibold)).tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("recentes, \(threads.count) conversa\(threads.count == 1 ? "" : "s") carregada\(threads.count == 1 ? "" : "s")")
                .accessibilityIdentifier(A11yID.searchRecentCaption)
            ForEach(threads) { t in
                SearchThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != threads.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}

struct SearchResultsSection: View {
    let results: [AtlasAiThread]
    let query: String
    let reduceMotion: Bool

    var body: some View {
        Group {
            Text("\(results.count) resultado\(results.count == 1 ? "" : "s")")
                .font(.system(.caption, weight: .semibold)).tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("\(results.count) conversa\(results.count == 1 ? "" : "s") com ‘\(query)’")
                .accessibilityIdentifier(A11yID.searchResultsCaption)
            ForEach(results) { t in
                SearchThreadLink(thread: t, reduceMotion: reduceMotion)
                if t.id != results.last?.id {
                    Divider().overlay(AtlasTheme.separator)
                        .padding(.leading, AtlasTheme.Space.screen + 36)
                }
            }
        }
    }
}
