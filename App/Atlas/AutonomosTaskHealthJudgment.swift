import Foundation
import AtlasCore

// MARK: - Task health / incident judgment (WAVE-036)

enum AutonomosTaskHealthFace: Equatable {
    case unbound
    case loading
    case quiet
    case incident(flagCount: Int)
    case pressure

    var productWord: String {
        switch self {
        case .unbound: return "unbound"
        case .loading: return "loading"
        case .quiet: return "quiet"
        case .incident: return "incident"
        case .pressure: return "pressure"
        }
    }

    var spokenFace: String {
        switch self {
        case .unbound: return "saúde da frota não ligada"
        case .loading: return "carregando saúde da frota"
        case .quiet: return "frota quieta, sem incidente publicado"
        case .incident(let n):
            return n == 1 ? "1 sinal de incidente" : "\(n) sinais de incidente"
        case .pressure: return "pressão de fila publicada"
        }
    }

    var heroTitle: String {
        switch self {
        case .unbound: return "Saúde unbound"
        case .loading: return "Lendo saúde…"
        case .quiet: return "Quiet"
        case .incident: return "Precisa de você"
        case .pressure: return "Pressão na fila"
        }
    }

    var heroSub: String {
        switch self {
        case .unbound:
            return "Sem área selecionada — não inventamos incidentes."
        case .loading:
            return "Só o que o servidor publicar em task health."
        case .quiet:
            return "Nenhum incidente. Silêncio honesto."
        case .incident:
            return "Sinais publicados — julgue a ação recomendada."
        case .pressure:
            return "Fila sob pressão; sem flag de incidente explícita."
        }
    }
}

enum AutonomosTaskHealthJudgment {

    static func incidentPresent(_ health: AtlasAutonomosTaskHealthResponse?) -> Bool {
        health?.incidents.present == true
    }

    static func face(
        areaSelected: Bool,
        health: AtlasAutonomosTaskHealthResponse?
    ) -> AutonomosTaskHealthFace {
        if !areaSelected { return .unbound }
        guard let health else { return .loading }
        if health.incidents.present {
            return .incident(flagCount: health.incidents.flags.count)
        }
        let pressure = health.operating.queuePressure
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if !pressure.isEmpty, pressure != "none", pressure != "low", pressure != "quiet", pressure != "ok" {
            return .pressure
        }
        if health.healthy {
            return .quiet
        }
        // Unhealthy without explicit incident flags — still pressure attention.
        return .pressure
    }

    static func flagLines(_ health: AtlasAutonomosTaskHealthResponse) -> [String] {
        health.incidents.flags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func tasksSummary(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let t = health.tasks
        return "claimable \(t.claimable) · claimed \(t.claimed) · blocked \(t.blocked) · completed \(t.completed)"
    }

    static func operatingLine(_ health: AtlasAutonomosTaskHealthResponse) -> String {
        let action = health.operating.recommendedAction
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let pressure = health.operating.queuePressure
            .trimmingCharacters(in: .whitespacesAndNewlines)
        var parts: [String] = []
        if !action.isEmpty { parts.append(action) }
        if !pressure.isEmpty { parts.append("pressão \(pressure)") }
        return parts.isEmpty ? "sem recomendação publicada" : parts.joined(separator: " · ")
    }

    static func hubIncidentMeta(health: AtlasAutonomosTaskHealthResponse?) -> String? {
        guard let health, health.incidents.present else { return nil }
        let n = health.incidents.flags.count
        if n == 0 { return "incidente" }
        return n == 1 ? "1 sinal" : "\(n) sinais"
    }

    static func packFacts(
        areaSelected: Bool,
        health: AtlasAutonomosTaskHealthResponse?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(areaSelected: areaSelected, health: health)
        facts.append("task_health_face: \(face.productWord)")
        guard areaSelected else {
            absences.append("task health sem área selecionada")
            return (facts, absences)
        }
        guard let health else {
            absences.append("task health não hidratado neste recorte")
            return (facts, absences)
        }
        facts.append("healthy: \(health.healthy ? "yes" : "no")")
        facts.append("incidents_present: \(health.incidents.present ? "yes" : "no")")
        facts.append("queue_pressure: \(health.operating.queuePressure)")
        facts.append("recommended_action: \(health.operating.recommendedAction)")
        facts.append("tasks: \(tasksSummary(health))")
        for flag in flagLines(health).prefix(8) {
            facts.append("incident_flag: \(flag)")
        }
        if !health.incidents.present {
            absences.append("sem incidente publicado — não invente alarme")
        }
        return (facts, absences)
    }
}
