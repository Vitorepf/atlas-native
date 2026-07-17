import AtlasCore
import SwiftUI

// Healthy mirror states — peel de AtlasCodeMirrorCard+Headline.
// Mirrored → AtlasCodeMirrorCard+Headline+Healthy+Mirrored.swift
// Pending → AtlasCodeMirrorCard+Headline+Healthy+Pending.swift
// Quiet → AtlasCodeMirrorCard+Headline+Healthy+Quiet.swift
// Active → AtlasCodeMirrorCard+Headline+Healthy+Active.swift
// QuietBranch → AtlasCodeMirrorCard+Headline+Healthy+QuietBranch.swift

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthy: some View {
        switch response.state {
        case .mirrored, .pending:
            headlineHealthyActive
        case .noMirror, .unknown:
            headlineHealthyQuiet
        default:
            EmptyView()
        }
    }
}
