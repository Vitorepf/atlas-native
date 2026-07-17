import SwiftUI
import AtlasCore

// Mount check row — peel de ArtifactSheet+MountChecks.
// Spoken → ArtifactSheet+MountSpoken.swift
// Texts → ArtifactSheet+MountCheckRow+Texts.swift

extension ArtifactSheet {
    func mountCheckRow(index: Int, check: ArtifactDeliveryCheck) -> some View {
        HStack(spacing: 8) {
            mountCheckRowTexts(check: check)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(check.spoken)
        .accessibilityIdentifier(A11yID.artifactsMountCheck(index))
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}
