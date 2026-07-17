import Foundation

/// Spoken labels do shell/rows compartilhados — peel de ConversationChrome (CICLO C).
/// Rótulo composto só com label/sub publicados; seleção explícita.

enum SheetShellA11y {
    static func spokenRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }
}
