import SwiftUI
import AtlasCore

// Schedule copy — peel de AutonomosDigestSection+Card.
// Next → AutonomosDigestSection+ScheduleCopyNext.swift
// Fallback → AutonomosDigestSection+ScheduleCopyFallback.swift

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestScheduleCopy(last: Bool) -> some View {
        if let next = digest.nextDigestAt?.nonEmpty {
            digestScheduleCopyNext(next)
        } else {
            digestScheduleCopyFallback(last: last)
        }
    }
}
