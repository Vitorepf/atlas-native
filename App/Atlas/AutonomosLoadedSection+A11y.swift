import Foundation
import AtlasCore

/// Spoken labels do corpo carregado — peel de AutonomosLoadedSection (CICLO C).
/// Recibos só com campos publicados; fila ≠ execução; erro = mensagem real do servidor.
/// StartRun → AutonomosLoadedSection+A11yStartRun.swift
/// Control → AutonomosLoadedSection+A11yControl.swift

enum AutonomosLoadedSectionA11y {
    static func spokenControlReceipt(_ receipt: AtlasAutonomosRunControlResponse) -> String {
        AutonomosLoadedSectionA11yControl.spokenControlReceipt(receipt)
    }

    static func spokenControlError(_ message: String) -> String {
        AutonomosLoadedSectionA11yControl.spokenControlError(message)
    }
}
