import SwiftUI
import AtlasCore

// Steer — peel de ExecutionStateCard+ActionButtons.
// Retry → ExecutionStateCard+Retry.swift
// Label → ExecutionStateCard+SteerLabel.swift

extension ExecutionStateCard {
    @ViewBuilder
    var steerButton: some View {
        if let onSteer {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSteer()
            } label: {
                steerButtonLabel
            }
            .buttonStyle(ExecutionStateActionStyle(
                style: .secondary,
                reduceMotion: reduceMotion
            ))
            .accessibilityLabel("redirecionar esta execução")
            .accessibilityHint("abre instrução para o próximo checkpoint seguro")
        }
    }
}
