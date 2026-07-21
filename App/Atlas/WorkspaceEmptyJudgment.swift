import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive workspace editorial-empty face (WAVE-078).
enum WorkspaceEmptyFace: Equatable {
    case area(String)
    case free
    case workspace(String)

    var productWord: String {
        switch self {
        case .area: return "area"
        case .free: return "free"
        case .workspace: return "workspace"
        }
    }

    var spokenFace: String {
        switch self {
        case .area(let label):
            return "nada em \(label)"
        case .free:
            return "nenhuma conversa sem projeto ainda"
        case .workspace(let title):
            return "nenhuma conversa em \(title) ainda"
        }
    }
}

// MARK: - Judgment

/// Pure workspace editorial-empty grammar — face · copy · pack.
enum WorkspaceEmptyJudgment {

    static func face(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> WorkspaceEmptyFace {
        if area != .tudo {
            return .area(area.label)
        }
        if freeOnly {
            return .free
        }
        return .workspace(screenTitle)
    }

    static func headline(face: WorkspaceEmptyFace) -> String {
        switch face {
        case .area(let label):
            return "“Nada em \(label) — por enquanto.”"
        case .free:
            return "“Nenhuma conversa sem projeto ainda.”"
        case .workspace(let title):
            return "“Nenhuma conversa em \(title) ainda.”"
        }
    }

    static func footnote(face: WorkspaceEmptyFace) -> String {
        switch face {
        case .free:
            return "perguntas e pensamento livre começam abaixo"
        case .area, .workspace:
            return "comece uma abaixo — o projeto é opcional"
        }
    }

    static func spokenLabel(face: WorkspaceEmptyFace) -> String {
        let lead: String
        switch face {
        case .area(let label):
            // Preserve area-in-screenTitle honesty when title known via pack only —
            // spoken lead matches prior: "nada em \(area) em \(screenTitle)" needs title.
            lead = "nada em \(label)"
        case .free:
            lead = face.spokenFace
        case .workspace(let title):
            lead = "nenhuma conversa em \(title) ainda"
        }
        return "\(lead). \(footnote(face: face))"
    }

    /// Full spoken with screen title for area case (prior honesty).
    static func spokenLabel(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> String {
        let face = face(area: area, freeOnly: freeOnly, screenTitle: screenTitle)
        switch face {
        case .area(let label):
            return "nada em \(label) em \(screenTitle). \(footnote(face: face))"
        default:
            return spokenLabel(face: face)
        }
    }

    static func packFacts(
        area: AtlasArea,
        freeOnly: Bool,
        screenTitle: String
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(area: area, freeOnly: freeOnly, screenTitle: screenTitle)
        facts.append("workspace_empty_face: \(face.productWord)")
        facts.append("workspace_empty_area: \(area.label)")
        facts.append("workspace_empty_title: \(screenTitle)")
        if freeOnly { facts.append("workspace_empty_free_only: true") }
        absences.append("nenhuma conversa neste recorte vazio")
        return (facts, absences)
    }
}
