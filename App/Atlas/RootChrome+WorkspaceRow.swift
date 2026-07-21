import AtlasCore
import SwiftUI

// Cycle 034 fuse → RootChrome+WorkspaceRow.swift

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowLeadingStack: some View {
        workspaceRowLeading
        workspaceRowNameStack
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var workspaceRowTrailingStack: some View {
        Spacer(minLength: 8)
        rowTrailing
    }
}

extension WorkspaceRow {
    var workspaceRowHBox: some View {
        HStack(spacing: 14) {
            workspaceRowLeadingStack
            workspaceRowTrailingStack
        }
    }
}

extension WorkspaceRow {
    var workspaceRowLeading: some View {
        // Hierarchical: o SF ganha profundidade de dois tons (régua premium).
        Image(systemName: icon)
            .symbolRenderingMode(.hierarchical)
            .atlasSans(18).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
            .accessibilityHidden(true)
    }
}

extension WorkspaceRow {
    var workspaceRowNameStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name).font(.system(.body)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            rowDetail
        }
    }
}

extension WorkspaceRow {
    var rowContent: some View {
        workspaceRowHBox
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, AtlasTheme.Space.row)
            .contentShape(Rectangle())
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowDetail: some View {
        // Voz calma: o ponto vermelho (badge) é o único alerta da linha —
        // texto em vermelho por cima dele era sinal duplicado gritando.
        if let detail, !detail.isEmpty {
            Text(detail)
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailing: some View {
        rowTrailingBadge
        rowTrailingCount
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingBadge: some View {
        if badge {
            Circle()
                .fill(AtlasTheme.alert)
                .frame(width: 8, height: 8)
                .accessibilityHidden(true)
        }
    }
}

extension WorkspaceRow {
    @ViewBuilder
    var rowTrailingCount: some View {
        if let count {
            // Número é meta: mono editorial quieto (ausência = ausência).
            Text("\(count)")
                .font(AtlasFont.mono(12, .medium))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
        Image(systemName: "chevron.right")
            .atlasSans(11, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary.opacity(0.55))
            .accessibilityHidden(true)
    }
}
