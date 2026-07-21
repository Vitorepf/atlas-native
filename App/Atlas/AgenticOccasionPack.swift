import Foundation

/// WAVE-020 — gramática canônica do pack de ocasião (casca only).
/// Eixos: surface · subject · anchors · facts · absences · can_do.
/// Hosts donos dos dados; este tipo só compila a forma — nunca inventa scores/write.
struct AgenticOccasionPack: Equatable {
    enum CanDo: String, Equatable {
        /// Chat NL de leitura/julgamento; sem tool write.
        case readChat = "read_chat"
        /// Só status/headline; sem chat útil além de perguntar.
        case statusOnly = "status_only"
        /// Run/stop/pause só via CTA da face — NL não autoriza write.
        case ctaOnlyRunStop = "cta_only_run_stop"
        /// Controles locais da face (pause/retomar) + chat de leitura.
        case faceCTALocal = "face_cta_local_plus_read_chat"
    }

    var surface: String
    var subject: String
    var anchors: [String] = []
    var facts: [String] = []
    var absences: [String] = []
    var canDo: CanDo
    /// Bloco opcional (ex.: server ask facts) anexado após a gramática.
    var appendix: String? = nil

    /// Render key:value estável — mesma forma em todas as faces ops.
    func render() -> String {
        var lines: [String] = [
            "surface: \(surface)",
            "subject: \(subject)",
        ]
        if anchors.isEmpty {
            lines.append("anchors: []")
        } else {
            lines.append("anchors:")
            for a in anchors {
                lines.append("- \(a)")
            }
        }
        if facts.isEmpty {
            lines.append("facts: []")
        } else {
            lines.append("facts:")
            for f in facts {
                lines.append("- \(f)")
            }
        }
        if absences.isEmpty {
            lines.append("absences: []")
        } else {
            lines.append("absences:")
            for a in absences {
                lines.append("- \(a)")
            }
        }
        lines.append("can_do: \(canDo.rawValue)")
        if let appendix = appendix?.trimmingCharacters(in: .whitespacesAndNewlines), !appendix.isEmpty {
            lines.append("---")
            lines.append("appendix:")
            lines.append(appendix)
        }
        return lines.joined(separator: "\n")
    }
}
