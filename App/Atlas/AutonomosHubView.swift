import SwiftUI
import AtlasCore

/// Hub de um Autônomo do operador — presença → fato → verbo → Evolução.
/// Vestimenta = `AutonomosHubVestment` canônico (WAVE-007); zero LocalVestment.
// MARK: - Hub host

struct AutonomosHubView: View {
    let unit: AutonomosUnit
    let vestment: AutonomosHubVestment
    let controlFace: AutonomosRunControlFace
    let controlReceiptLine: String?
    /// WAVE-034: Evolução nav meta from delivered judgment.
    var evolutionMeta: String = "sem provas"
    /// WAVE-035: mission transfer when area canControl.
    var canTransfer: Bool = false
    var transferReceiptLine: String? = nil
    /// WAVE-036: task-health incident nav meta when present.
    var incidentMeta: String? = nil
    /// WAVE-038: digest/moment nav meta when published.
    var digestMeta: String? = nil
    /// WAVE-065: multi-area bind — show chooser CTA when needsBind.
    var needsAreaBind: Bool = false
    var registeredAreaCount: Int = 0
    var onChooseArea: () -> Void = {}
    let onNavigate: (AutonomosDestination) -> Void
    let onControl: (AutonomosRunControlAction) -> Void
    var onTransfer: () -> Void = {}
    let onLocalCatalogPause: () -> Void
    let onLocalCatalogResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(kickerLine, live: vestment.kickerLive)
                    .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(vestment.heroTitle)
                    .padding(.bottom, 10)
                Text(unit.charter)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 12)

                if needsAreaBind {
                    AutonomosAreaBindCTA(
                        registeredCount: registeredAreaCount,
                        onChoose: onChooseArea
                    )
                    .padding(.bottom, 16)
                }

                if AutonomosHubJudgment.showsControlFaceLine(controlFace) {
                    Text(controlFace.spokenFace)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.bottom, 16)
                        .accessibilityLabel(controlFace.spokenFace)
                }

                primaryVerb
                    .padding(.bottom, 8)

                if let secondary = AutonomosRunControlJudgment.secondaryAction(for: controlFace) {
                    AutonomosMapNavLine(
                        title: secondary.ctaTitle,
                        meta: controlFace.productWord,
                        action: { onControl(secondary) }
                    )
                }

                if let controlReceiptLine, !controlReceiptLine.isEmpty {
                    Text(controlReceiptLine)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(
                            controlReceiptTone == .error
                                ? AtlasTheme.domOperacional
                                : AtlasTheme.textSecondary
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 10)
                        .padding(.bottom, 4)
                        .accessibilityIdentifier(A11yID.autonomosControlError)
                        .accessibilityValue(controlReceiptTone.productWord)
                }

                if let transferReceiptLine, !transferReceiptLine.isEmpty {
                    Text(transferReceiptLine)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                        .accessibilityLabel(transferReceiptLine)
                }

                AutonomosMapChrome.hairline
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                AutonomosMapNavLine(
                    title: "Evolução",
                    meta: evolutionMeta,
                    action: { onNavigate(.evolution) }
                )

                if let incidentMeta {
                    AutonomosMapNavLine(
                        title: "Precisa de você",
                        meta: incidentMeta,
                        action: { onNavigate(.incident) }
                    )
                }

                if let digestMeta {
                    AutonomosMapNavLine(
                        title: "Digest",
                        meta: digestMeta,
                        action: { onNavigate(.moment("digest")) }
                    )
                }

                if canTransfer {
                    AutonomosMapNavLine(
                        title: AutonomosTransferJudgment.ctaTitle,
                        meta: AutonomosTransferJudgment.productWord,
                        action: onTransfer
                    )
                }

                catalogPauseLine

                if unit.paused {
                    AutonomosMapNavLine(title: "Encerrar", meta: "", action: onEnd)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosHub)
        .accessibilityLabel(hubSpokenLabel)
        .accessibilityValue(hubFace.productWord)
    }

    private var hubFace: AutonomosHubFace {
        AutonomosHubJudgment.face(vestment: vestment, needsAreaBind: needsAreaBind)
    }

    private var kickerLine: String {
        AutonomosHubJudgment.kickerLine(vestment: vestment, ageLabel: unit.ageLabel)
    }

    private var hubSpokenLabel: String {
        AutonomosHubJudgment.spokenHub(
            name: unit.name,
            vestment: vestment,
            controlFace: controlFace,
            needsAreaBind: needsAreaBind
        )
    }

    private var controlReceiptTone: AutonomosReceiptTone {
        AutonomosHubJudgment.receiptTone(line: controlReceiptLine)
    }

    @ViewBuilder
    private var primaryVerb: some View {
        // Precedence: awaiting decisions (026) → wire control (030) → local catalog.
        switch vestment {
        case .awaiting(let count):
            AutonomosMapChrome.primaryCTA(
                AutonomosDecisionJudgment.primaryCTATitle(count: count),
                action: { onNavigate(.decisions) }
            )
        case .live, .quiet:
            if let action = AutonomosRunControlJudgment.primaryAction(for: controlFace) {
                AutonomosMapChrome.primaryCTA(action.ctaTitle, action: { onControl(action) })
            } else if case .quiet = vestment {
                // Catalog-only resume when loop unbound.
                AutonomosMapChrome.primaryCTA("Retomar na lista", action: onLocalCatalogResume)
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var catalogPauseLine: some View {
        let demote = AutonomosRunControlJudgment.demoteLocalPause(
            canControl: controlFace != .unbound && controlFace != .unregistered
        )
        if demote {
            AutonomosMapNavLine(
                title: unit.paused ? "Retomar na lista" : "Só lista local",
                meta: unit.paused ? "iPhone · não é o loop" : "não pausa o servidor",
                action: {
                    if unit.paused { onLocalCatalogResume() } else { onLocalCatalogPause() }
                }
            )
        } else if unit.paused {
            AutonomosMapNavLine(title: "Retomar na lista", meta: "catálogo local", action: onLocalCatalogResume)
        } else {
            AutonomosMapNavLine(title: "Pausar na lista", meta: "catálogo local", action: onLocalCatalogPause)
        }
    }
}
