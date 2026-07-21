import AtlasCore
import SwiftUI

// Headline states — peel de AtlasCodeMirrorCard.
// Healthy → AtlasCodeMirrorCard+Headline+Healthy.swift
// Blocked → AtlasCodeMirrorCard+Headline+Blocked.swift

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headline: some View {
        headlineBlocked
        headlineHealthy
    }
}
