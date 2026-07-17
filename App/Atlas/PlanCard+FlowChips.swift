import SwiftUI
import AtlasCore

// Chips em fluxo para agentes/ferramentas/gates — peel de PlanCard+Steps.
// Pai combina spoken via PlanCard.spokenChipRow; chips individuais silenciosos.

struct PlanFlowChips: View {
    let items: [String]
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            PlanFlexWrap(spacing: 6, lineSpacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityHidden(true)
        }
    }
}

/// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
struct PlanFlexWrap: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
