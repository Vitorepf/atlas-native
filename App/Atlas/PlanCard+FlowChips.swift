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
                    flowChipCell(item)
                }
            }
            .accessibilityHidden(true)
        }
    }
}
