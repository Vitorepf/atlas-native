import SwiftUI

/// Labels falados — peel de QueuedFollowUpRow (régua ≤100).
/// Buttons → QueuedFollowUpRow+Buttons.swift

extension QueuedFollowUpRow {
    var positionCaption: String {
        let ordinal = index + 1
        if ordinal == 1 { return "próxima na fila" }
        return "\(ordinal)ª na fila"
    }

    var rowSpokenLabel: String {
        let ordinal = index + 1
        if total == 1 { return message.text }
        if ordinal == 1 { return "primeira na fila, \(total) no total. \(message.text)" }
        return "\(ordinal)ª de \(total) na fila. \(message.text)"
    }

    var promoteLabel: String { "enviar agora, \(positionCaption): \(message.text)" }
    var promoteHint: String { "torna esta mensagem a próxima instrução; o turno atual continua" }
    var removeLabel: String { "remover da fila, \(positionCaption): \(message.text)" }
    var removeHint: String { "remove da fila sem enviar" }
}
