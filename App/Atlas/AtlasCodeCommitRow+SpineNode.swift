import SwiftUI
import AtlasCore

// Spine node — peel de AtlasCodeCommitRow+SpineParts.
// ViolatingRing → AtlasCodeCommitRow+SpineNode+ViolatingRing.swift
// CoreDot → AtlasCodeCommitRow+SpineNode+CoreDot.swift

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineNode(motion: Animation?) -> some View {
        ZStack {
            spineViolatingRing(motion: motion)
            spineCoreDot
        }
        .frame(width: 22, height: 22)
        .animation(motion, value: state == .violating)
    }
}
