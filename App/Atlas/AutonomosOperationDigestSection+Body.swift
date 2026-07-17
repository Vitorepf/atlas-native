import SwiftUI
import AtlasCore

// Corpo com sinal publicado — peel de AutonomosOperationDigestSection.
// Spoken → AutonomosOperationDigestSection+Body+Spoken.swift
// Identifier → AutonomosOperationDigestSection+Body+Identifier.swift
// Quiet → +Quiet · Meta → +SignalMeta
// Chrome → AutonomosOperationDigestSection+BodyChrome.swift
// Stack → AutonomosOperationDigestSection+BodyStack.swift

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestSignalBody: some View {
        digestSignalIdentifier(
            digestSignalSpoken(
                digestSignalChrome {
                    digestSignalStack
                }
            )
        )
    }
}
