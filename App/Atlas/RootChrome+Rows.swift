import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → RootChrome+Rows.swift

/// Contagem zero = «nenhuma conversa»; badge só quando o model marca atenção real.

enum RootChromeRowA11y {
    static func workspaceSpoken(
        name: String,
        count: Int?,
        detail: String?,
        badge: Bool
    ) -> String {
        var parts = [name]
        if let count {
            parts.append(workspaceCountPart(count))
        }
        parts.append(contentsOf: workspaceDetailParts(detail: detail, badge: badge))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func workspaceCountPart(_ count: Int) -> String {
        if count == 0 {
            return "nenhuma conversa"
        }
        return "\(count) conversa\(count == 1 ? "" : "s")"
    }
}

extension RootChromeRowA11y {
    static func workspaceDetailParts(detail: String?, badge: Bool) -> [String] {
        var parts: [String] = []
        if let detail, !detail.isEmpty {
            parts.append(detail)
        }
        if badge {
            parts.append("atenção necessária")
        }
        return parts
    }
}

extension RootChromeRowA11y {
    static func threadSpoken(
        title: String,
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> String {
        var parts = [title]
        parts.append(contentsOf: threadStatusParts(
            messageCount: messageCount,
            isRunning: isRunning,
            isNew: isNew,
            hasWorkspace: hasWorkspace
        ))
        return parts.joined(separator: ", ")
    }
}

extension RootChromeRowA11y {
    static func spokenThreadMessageCount(_ messageCount: Int) -> [String] {
        if messageCount == 0 {
            return ["nenhuma mensagem"]
        }
        return ["\(messageCount) mensagem\(messageCount == 1 ? "" : "ns")"]
    }
}

extension RootChromeRowA11y {
    static func threadHint(isRunning: Bool) -> String {
        isRunning ? "Atlas executando nesta conversa" : "abre a conversa"
    }
}

extension RootChromeRowA11y {
    static func threadMessageParts(messageCount: Int, isRunning: Bool) -> [String] {
        if isRunning { return spokenThreadRunning() }
        return spokenThreadMessageCount(messageCount)
    }
}

extension RootChromeRowA11y {
    static func spokenThreadRunning() -> [String] {
        ["Atlas executando"]
    }
}

extension RootChromeRowA11y {
    static func threadStatusParts(
        messageCount: Int,
        isRunning: Bool,
        isNew: Bool,
        hasWorkspace: Bool
    ) -> [String] {
        var parts = threadMessageParts(messageCount: messageCount, isRunning: isRunning)
        if isNew && !isRunning {
            parts.append("novo desde a última visita")
        }
        if hasWorkspace {
            parts.append("com workspace")
        }
        return parts
    }
}

struct WorkspaceRow: View {
    let icon: String
    let name: String
    let count: Int?
    var detail: String?
    var badge: Bool = false
    /// Voz/identidade vivem NO botão: rotular por fora cria um invólucro
    /// `Other` mudo por cima e apaga o botão para VoiceOver e XCUITest.
    var a11yID: String?
    var spokenOverride: String?
    var spokenHint: String?
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Button(action: action) {
            rowContent
        }
        .buttonStyle(.plain)
        // Sem accessibilityElement(children:) aqui: Button JÁ é elemento de
        // a11y; recriar o elemento gera um invólucro `Other` e emudece o botão.
        .accessibilityLabel(spokenOverride ?? RootChromeRowA11y.workspaceSpoken(name: name, count: count, detail: detail, badge: badge))
        .accessibilityHint(spokenHint ?? "abre \(name)")
        .accessibilityIdentifier(a11yID ?? "")
    }
}

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
