import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive multi-area bind face (WAVE-065).
enum AutonomosAreaBindFace: Equatable {
    /// Zero registered areas — silence, no theater.
    case none
    /// Exactly one registered (or defaultArea match) — auto-bind path.
    case auto
    /// N>1 registered and nothing selected — operator must choose.
    case needsBind(Int)
    /// Area selected.
    case bound(String)

    var productWord: String {
        switch self {
        case .none: return "none"
        case .auto: return "auto"
        case .needsBind: return "needs_bind"
        case .bound: return "bound"
        }
    }

    var spokenFace: String {
        switch self {
        case .none:
            return "nenhuma área registrada no motor"
        case .auto:
            return "uma área registrada, ligação automática"
        case .needsBind(let n):
            return "escolher área, \(n) áreas registradas"
        case .bound(let name):
            return "área \(name)"
        }
    }

    var needsChooser: Bool {
        if case .needsBind = self { return true }
        return false
    }
}

// MARK: - Judgment

/// Pure area-bind policy — 0/1/N · face · pack · rank for chooser.
enum AutonomosAreaBindJudgment {

    static func registeredAreas(_ areas: [AtlasAutonomosArea]) -> [AtlasAutonomosArea] {
        areas.filter(\.registered)
    }

    /// WAVE-030 law: 1 registered → that id; defaultArea match when multi; else nil.
    static func autoBindID(
        areas: [AtlasAutonomosArea],
        defaultArea: String? = nil
    ) -> String? {
        AutonomosRunControlJudgment.bindAreaID(areas: areas, defaultArea: defaultArea)
    }

    static func face(
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        defaultArea: String? = nil
    ) -> AutonomosAreaBindFace {
        if let selectedAreaID,
           let area = areas.first(where: { $0.id == selectedAreaID }) {
            return .bound(area.areaName.isEmpty ? area.id : area.areaName)
        }
        let registered = registeredAreas(areas)
        if registered.isEmpty { return .none }
        if autoBindID(areas: areas, defaultArea: defaultArea) != nil {
            return .auto
        }
        return .needsBind(registered.count)
    }

    /// Stable chooser order: name, then id.
    static func rankForChooser(_ areas: [AtlasAutonomosArea]) -> [AtlasAutonomosArea] {
        registeredAreas(areas).sorted { lhs, rhs in
            let ln = lhs.areaName.lowercased()
            let rn = rhs.areaName.lowercased()
            if ln != rn { return ln < rn }
            return lhs.id < rhs.id
        }
    }

    static func spokenChooserRow(_ area: AtlasAutonomosArea) -> String {
        var parts = [area.areaName.isEmpty ? area.id : area.areaName]
        if !area.focus.isEmpty {
            parts.append("foco \(area.focus)")
        }
        parts.append("registrada")
        return parts.joined(separator: ", ")
    }

    static func spokenChooser(count: Int) -> String {
        "escolher área do loop, \(count) área\(count == 1 ? "" : "s") registrada\(count == 1 ? "" : "s")"
    }

    static let chooserHint = "liga a frota a uma área registrada no motor"
    static let ctaTitle = "Escolher área"
    static let ctaSpoken = "escolher área do loop Autônomos"

    static func packFacts(
        areas: [AtlasAutonomosArea],
        selectedAreaID: String?,
        defaultArea: String? = nil
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(areas: areas, selectedAreaID: selectedAreaID, defaultArea: defaultArea)
        let registered = registeredAreas(areas)
        facts.append("area_bind_face: \(face.productWord)")
        facts.append("areas_registered: \(registered.count)")
        facts.append("areas_total: \(areas.count)")
        switch face {
        case .none:
            absences.append("nenhuma área registered — silenciam órgãos de loop")
        case .auto:
            facts.append("area_bind_policy: auto_single")
        case .needsBind:
            absences.append("multi-área sem seleção — chooser necessário")
        case .bound(let name):
            facts.append("area_selected_name: \(name)")
            if let id = selectedAreaID {
                facts.append("area_selected_id: \(id)")
            }
        }
        return (facts, absences)
    }
}
