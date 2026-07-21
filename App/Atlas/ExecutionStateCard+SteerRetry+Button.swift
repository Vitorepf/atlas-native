import SwiftUI
import AtlasCore

// Steer button chrome — peel de ExecutionStateCard+SteerRetry.

extension ExecutionStateCard {
    @ViewBuilder
    var steerActionButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSteer?()
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
