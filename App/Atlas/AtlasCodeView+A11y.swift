import Foundation
import AtlasCore

/// Spoken screen label — peel de AtlasCodeView (CICLO C residual honesty).
/// Loaded → AtlasCodeView+A11y+Loaded.swift
/// Busy → AtlasCodeView+A11y+Busy.swift

extension AtlasCodeView {
    func spokenCodeScreenLabel() -> String {
        spokenCodeScreenBusyLabel() ?? spokenCodeScreenLoadedLabel()
    }

    static let codeScreenHint = "mapa governado; pílula e proveniência só com dados publicados"
}
