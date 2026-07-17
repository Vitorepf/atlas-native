import Foundation
import AtlasCore

/// Spoken labels do seletor de instâncias — peel de AutonomosAreaPicker (CICLO C).
/// Fase canônica do Core; `registered` só quando o payload nega registro.

enum AutonomosAreaPickerA11y {
    static func spokenSection(count: Int) -> String {
        guard count > 0 else { return "instâncias, nenhuma área publicada" }
        return "instâncias, \(count) área\(count == 1 ? "" : "s")"
    }

    static func spokenRow(
        _ area: AtlasAutonomosArea,
        index: Int,
        total: Int,
        isSelected: Bool
    ) -> String {
        var parts = ["instância \(index + 1) de \(total)", area.areaName]
        let objective = area.objective.trimmingCharacters(in: .whitespacesAndNewlines)
        if !objective.isEmpty { parts.append(objective) }
        parts.append(spokenPhase(area.loopStatus.phase))
        if !area.registered { parts.append("não registrada no servidor") }
        if isSelected { parts.append("selecionada") }
        return parts.joined(separator: ", ")
    }

    static func spokenRowHint() -> String {
        "seleciona esta instância para ver detalhes e controles"
    }

    private static func spokenPhase(_ phase: AtlasAutonomosLoopPhase) -> String {
        switch phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }
}
