import SwiftUI
import AtlasCore

/// C13: saúde da fila do músculo externo — contagens verificáveis, nunca
/// "plano/progresso"; saudável = uma linha quieta; alerta só com incidente.
/// Bodies → AutonomosFleetTaskHealth+Bodies.swift
struct AutonomosTaskHealthSection: View {
    let health: AtlasAutonomosTaskHealthResponse
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        Group {
            if health.incidents.present {
                incidentBody
            } else {
                quietBody
            }
        }
    }
}
