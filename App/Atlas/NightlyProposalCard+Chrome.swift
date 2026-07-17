import SwiftUI

// Chrome visual do card — peel de NightlyProposalCard.

extension NightlyProposalCard {
    var cardChrome: some View {
        VStack(alignment: .leading, spacing: 12) {
            masthead
            copyBlock
            actionRow
        }
        .padding(14)
        .atlasCard(cornerRadius: 14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }
}
