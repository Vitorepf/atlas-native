import SwiftUI

/// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
/// Peel de PlanCard+FlowChips.
/// Place → PlanCard+FlexWrapPlace.swift
/// Measure → PlanCard+FlexWrap+Measure.swift
struct PlanFlexWrap: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let measured = measureFlexWrap(maxWidth: maxWidth, subviews: subviews)
        return CGSize(
            width: maxWidth == .infinity ? measured.width : maxWidth,
            height: measured.height
        )
    }
}
