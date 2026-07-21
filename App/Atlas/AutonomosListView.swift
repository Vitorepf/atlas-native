import SwiftUI

/// Lista de Autônomos do operador — índice soberano (WAVE-090 Judgment).
/// Vazio até criar. Zero áreas de sistema.
struct AutonomosListView: View {
    let units: [AutonomosUnit]
    /// WAVE-026: unit IDs with hydrated awaiting signal only — never invent.
    var awaitingUnitIDs: Set<String> = []
    let onOpen: (AutonomosUnit) -> Void
    let onCreate: () -> Void

    private var listFace: AutonomosListFace {
        AutonomosListJudgment.listFace(unitCount: units.count)
    }

    var body: some View {
        Group {
            if listFace == .empty {
                emptyState
            } else {
                list
            }
        }
        .accessibilityIdentifier(A11yID.autonomosList)
        .accessibilityValue(listFace.productWord)
    }

    /// WAVE-026/090: awaiting (hydrated) → live → quiet/paused last.
    private var judgmentUnits: [AutonomosUnit] {
        AutonomosListJudgment.rankUnits(units, awaitingUnitIDs: awaitingUnitIDs)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(judgmentUnits) { unit in
                    unitRow(unit)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 36)
            AutonomosMapChrome.heroTitle(AutonomosListJudgment.emptyHero, size: 32)
            Text(AutonomosListJudgment.emptyBody)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(AutonomosListJudgment.emptyFootnote)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            AutonomosMapChrome.primaryCTA(AutonomosListJudgment.createCTA, action: onCreate)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosListJudgment.spokenEmpty())
        .accessibilityHint(AutonomosListJudgment.emptyHint)
        .accessibilityValue(listFace.productWord)
    }

    private func unitRow(_ unit: AutonomosUnit) -> some View {
        let face = AutonomosListJudgment.rowFace(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
        return Button {
            onOpen(unit)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.name)
                        .font(AtlasFont.serif(22, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                trailing(face)
            }
            .padding(.vertical, 22)
            .opacity(unit.paused ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            AutonomosListJudgment.spokenRow(unit: unit, awaitingUnitIDs: awaitingUnitIDs)
        )
        .accessibilityValue(face.productWord)
    }

    @ViewBuilder
    private func trailing(_ face: AutonomosListRowFace) -> some View {
        switch face {
        case .awaiting, .quiet:
            Text(face.productWord)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(face == .awaiting ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .textCase(.uppercase)
                .padding(.top, 6)
                .accessibilityLabel(face.spokenFace)
        case .live:
            Circle()
                .fill(AtlasTheme.accent.opacity(0.85))
                .frame(width: 5, height: 5)
                .padding(.top, 10)
                .accessibilityLabel(face.spokenFace)
        }
    }
}
