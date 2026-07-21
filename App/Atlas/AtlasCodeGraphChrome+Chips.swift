import SwiftUI
import AtlasCore

// Filter tabs row — peel de AtlasCodeGraphChrome+Filters.

extension AtlasCodeView {
    func graphStateChips(_ graph: AtlasCodeGraphResponse, filterSilence: Bool) -> some View {
        HStack(spacing: 0) {
            graphStateChipLoop(graph, filterSilence: filterSilence)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AtlasTheme.separator.opacity(0.85))
                .frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.codeGraphFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: graphStateFilter)
    }
}
