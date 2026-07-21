import SwiftUI
import AtlasCore

// Detalhe do plano: toggle ferramentas/agentes/gates + flow chips + flex wrap.
// Peel forest fused cycle 019 (DetailToggle/Chips/Flow/FlexWrap peels).

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            planDetailToggleButton(plan: plan)
            if showDetail { planDetail(plan) }
        }
    }

    @ViewBuilder
    func planDetailToggleButton(plan: AtlasExecutionPlan) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showDetail.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showDetail ? "menos" : "ferramentas · agentes · gates")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.planDetailToggle)
        .accessibilityLabel(showDetail ? "ocultar ferramentas agentes e gates" : "mostrar ferramentas agentes e gates")
        .accessibilityHint(showDetail ? "toque para recolher" : "toque para expandir")
    }

    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            planAgentsChips(plan)
            planToolsChips(plan)
            planGatesChips(plan)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenPlanDetail(plan))
        .transition(reduceMotion ? .identity : .opacity)
    }

    @ViewBuilder
    func planAgentsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.agents.isEmpty {
            chipRow(label: "agentes", items: plan.agents.map(\.title))
        }
    }

    @ViewBuilder
    func planToolsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty {
            chipRow(label: "ferramentas", items: plan.tools.map(\.label))
        }
    }

    @ViewBuilder
    func planGatesChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.qualityGates.isEmpty {
            chipRow(label: "gates", items: plan.qualityGates.map(\.label))
        }
    }

    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenChipRow(label: label, items: items))
    }
}

/// Chips em fluxo para agentes/ferramentas/gates.
/// Pai combina spoken via PlanCard.spokenChipRow; chips individuais silenciosos.
struct PlanFlowChips: View {
    let items: [String]
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            PlanFlexWrap(spacing: 6, lineSpacing: 6) {
                ForEach(items, id: \.self) { item in
                    flowChipCell(item)
                }
            }
            .accessibilityHidden(true)
        }
    }

    func flowChipCell(_ item: String) -> some View {
        Text(item)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

/// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
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

    func measureFlexWrap(
        maxWidth: CGFloat,
        subviews: Subviews
    ) -> (width: CGFloat, height: CGFloat) {
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (x, y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            placeFlexWrapSubview(sub, x: &x, y: &y, lineHeight: &lineHeight, bounds: bounds)
        }
    }

    func placeFlexWrapSubview(
        _ sub: LayoutSubview,
        x: inout CGFloat,
        y: inout CGFloat,
        lineHeight: inout CGFloat,
        bounds: CGRect
    ) {
        let size = sub.sizeThatFits(.unspecified)
        if x + size.width > bounds.maxX, x > bounds.minX {
            x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
        }
        sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
        x += size.width + spacing
        lineHeight = max(lineHeight, size.height)
    }
}
