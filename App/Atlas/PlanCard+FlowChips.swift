import SwiftUI
import AtlasCore

// Chips em fluxo para agentes/ferramentas/gates — peel de PlanCard+Steps.
// Layout → PlanCard+FlexWrap.swift
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
