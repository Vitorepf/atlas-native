import SwiftUI
import AtlasCore

/// Spoken helpers — peel de LiveNowRow (CICLO C residual honesty).
/// Spoken label → LiveNowRow+Spoken.swift
/// Clock → LiveNowRow+A11yClock.swift

extension LiveNowRow {
    var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
    }

    func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }
}
