import SwiftUI
import AtlasCore

// User turn block — peel de EditorialTurn.
// Quote → EditorialTurn+UserQuote.swift
// Edit → EditorialTurn+UserEdit.swift

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            userEditResendButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
