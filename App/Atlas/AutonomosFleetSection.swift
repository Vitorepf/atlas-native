import SwiftUI
import AtlasCore

/// Frota global — agentes reais, saúde da fila, histórico e handoff (C13).
/// Summary → AutonomosFleetSection+Summary.swift · Body → +Body.swift
/// A11y → AutonomosFleetSection+A11yChrome.swift
struct AutonomosFleetSection: View {
    let fleet: AtlasAutonomosFleetResponse
    /// Incidente da fila (C13) — saudável = header quieto; barulho só por exceção.
    var incidentPresent: Bool = false
    var auditModeEnabled: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var isQuiet: Bool {
        AutonomosFleetHealth.isQuiet(fleet: fleet, incidentPresent: incidentPresent)
    }

    var body: some View {
        fleetA11yChrome(fleetSectionBody)
    }
}
