import AtlasCore
import Foundation
import SwiftUI

// Cycle 034 fuse → RootChrome+Rows.swift

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
