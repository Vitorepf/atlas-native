import AtlasCore
import SwiftUI

// Cycle 039 fuse → AtlasCodeMirrorCard+Headline.swift

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineBlocked: some View {
        if case .blocked = response.state {
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyActive: some View {
        switch response.state {
        case .mirrored:
            headlineHealthyMirrored
        case .pending(let commits):
            headlineHealthyPending(commits: commits)
        default:
            EmptyView()
        }
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyMirrored: some View {
        label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    func headlineHealthyPending(commits: Int) -> some View {
        label(
            commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
            color: AtlasTheme.textSecondary,
            icon: "internaldrive"
        )
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyNoMirror: some View {
        label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
    }

    @ViewBuilder
    var headlineHealthyUnknown: some View {
        label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
    }
}

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyQuiet: some View {
        switch response.state {
        case .noMirror:
            headlineHealthyNoMirror
        case .unknown:
            headlineHealthyUnknown
        default:
            EmptyView()
        }
    }
}

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

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headline: some View {
        headlineBlocked
        headlineHealthy
    }
}
