import AtlasCore
import SwiftUI

// Healthy mirror states — peel de AtlasCodeMirrorCard+Headline.
// Mirrored → AtlasCodeMirrorCard+Headline+Healthy+Mirrored.swift
// Pending → AtlasCodeMirrorCard+Headline+Healthy+Pending.swift
// Quiet → AtlasCodeMirrorCard+Headline+Healthy+Quiet.swift

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthy: some View {
        switch response.state {
        case .mirrored:
            headlineHealthyMirrored
        case .pending(let commits):
            headlineHealthyPending(commits: commits)
        case .noMirror:
            headlineHealthyNoMirror
        case .unknown:
            headlineHealthyUnknown
        default:
            EmptyView()
        }
    }
}
