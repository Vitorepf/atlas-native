import SwiftUI
import AtlasCore

// Botão editar/reenviar — peel de EditorialTurn+User.
// Label → EditorialTurn+UserEditLabel.swift

extension EditorialTurn {
    var userEditResendButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onEditResend()
        } label: {
            userEditResendLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("editar esta mensagem e reenviar como novo turno")
        .accessibilityHint("abre o compositor com este texto para um novo envio")
    }
}
