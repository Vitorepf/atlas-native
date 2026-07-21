import SwiftUI
import AtlasCore

/// Shell Autônomos v9 — catálogo do operador → hub → evolução · pílula · Novo.
struct AutonomosMapShell: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let model: AutonomosModel
    @Binding var destination: AutonomosDestination?
    @Binding var selectedUnitID: String?
    @Binding var showNewSheet: Bool
    @State private var showingAsk = false
    @State private var askThreadId: ThreadID?
    @State private var confirmEnd = false
    @State private var selfConstructionReceipt: SelfConstructionReceipt?
    @State private var nightly = NightlyProposalController.shared
    @State private var nightlyStartProposal: NightlyProposalController.ProposalPayload?

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var vestmentForAsk: AutonomosHubVestment {
        guard let unit = selectedUnit else { return .quiet }
        return unit.paused ? .quiet : .live
    }

    /// Só ciclos com merge real — nunca fabrica “melhorou”.
    private var latestMergeProvedReceipt: SelfConstructionReceipt? {
        guard let cycles = model.delivered?.delivered else { return nil }
        guard let cycle = cycles.first(where: { $0.mergePerformed && !$0.mergeHash.isEmpty }) else {
            return nil
        }
        return SelfConstructionReceipt(cycle: cycle, finding: nil)
    }

    var body: some View {
        Group {
            if let destination {
                route(destination)
            } else {
                catalogFace
            }
        }
        .sheet(isPresented: $showNewSheet) {
            AutonomosNewSheet(
                onCreate: { name, charter in
                    let unit = model.createOperatorUnit(name: name, charter: charter)
                    showNewSheet = false
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCancel: { showNewSheet = false }
            )
        }
        .sheet(item: $selfConstructionReceipt) { receipt in
            SelfConstructionReceiptSheet(receipt: receipt)
        }
        .sheet(item: $nightlyStartProposal) { proposal in
            AutonomosReasonSheet(
                title: "Preparar missão noturna",
                explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
                reasonOptional: true,
                initialReason: proposal.prefilledReason
            ) { actor, reason in
                Task {
                    let previous = model.lastStartRunReceipt
                    await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
                    if model.lastStartRunReceipt != previous,
                       model.lastStartRunReceipt?.isEnqueued == true {
                        await nightly.accept(proposal)
                    }
                }
            }
        }
        .confirmationDialog("Encerrar este Autônomo?", isPresented: $confirmEnd, titleVisibility: .visible) {
            Button("Encerrar de vez", role: .destructive) {
                // Medium: governed destructive commit (lista local).
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                deleteSelected()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Sai da sua lista. O motor no servidor ainda não liga a isto.")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
        .onAppear {
            #if DEBUG
            nightly.installDemoIfRequested()
            #endif
        }
    }

    /// Catálogo do operador + baseline Nightly/Ritmo (aprender-com-o-uso).
    private var catalogFace: some View {
        VStack(spacing: 0) {
            if let receipt = latestMergeProvedReceipt {
                selfConstructionBanner(receipt)
            }
            VStack(alignment: .leading, spacing: 12) {
                AutonomosNightlyProposalBlock(nightly: nightly) { proposal in
                    nightlyStartProposal = proposal
                }
                AutonomosRhythmLearningLine()
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .padding(.bottom, 4)

            AutonomosListView(
                units: model.operatorUnits,
                onOpen: { unit in
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCreate: { showNewSheet = true }
            )
        }
    }

    private func selfConstructionBanner(_ receipt: SelfConstructionReceipt) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            selfConstructionReceipt = receipt
        } label: {
            HStack(spacing: 10) {
                Text("✦")
                    .font(AtlasFont.serif(14, .semibold))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("O Atlas melhorou o próprio app")
                        .font(AtlasFont.serif(15, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    Text("Merge comprovado · toque o recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .accessibilityHidden(true)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
            .background(AtlasTheme.surface.opacity(0.55))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("O Atlas melhorou o próprio app, recibo com merge comprovado")
        .accessibilityHint("abre o recibo de auto-construção")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(8) // rare proven receipt — surface early in VO
        .accessibilityIdentifier(A11yID.autonomosSelfConstructionBanner)
    }

    @ViewBuilder
    private func route(_ destination: AutonomosDestination) -> some View {
        switch destination {
        case .hub:
            if let unit = selectedUnit {
                AutonomosHubView(
                    unit: unit,
                    onNavigate: { self.destination = $0 },
                    onPause: { model.setOperatorUnitPaused(id: unit.id, paused: true) },
                    onResume: { model.setOperatorUnitPaused(id: unit.id, paused: false) },
                    onEnd: { confirmEnd = true }
                )
            } else {
                missingUnit
            }
        case .evolution:
            AutonomosEvolutionView(unit: selectedUnit)
        case .decisions, .decisionInbox, .decisionOrder, .moment, .incident:
            VStack(alignment: .leading, spacing: 12) {
                AutonomosMapChrome.heroTitle("Ainda no escopo local", size: 26)
                Text("Decisões e momentos do motor chegam quando o create no Server existir.")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(AtlasTheme.Space.screen)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Ainda no escopo local. Decisões e momentos do motor chegam quando o create no Server existir."
            )
            .accessibilityIdentifier(A11yID.autonomosDeferredSurface)
        }
    }

    private var missingUnit: some View {
        VStack(alignment: .leading, spacing: 12) {
            AutonomosMapChrome.heroTitle("Autônomo ausente", size: 26)
            Text("Volte à lista e abra de novo.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Autônomo ausente. Volte à lista e abra de novo.")
        .accessibilityIdentifier(A11yID.autonomosMissingUnit)
    }

    private func deleteSelected() {
        guard let id = selectedUnitID else { return }
        model.removeOperatorUnit(id: id)
        selectedUnitID = nil
        destination = nil
    }

    private var askPillDock: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg.opacity(0.92), AtlasTheme.bg],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 28)
            .allowsHitTesting(false)
            AgenticPill(
                invite: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
                accessibilityId: A11yID.autonomosAskPill
            ) {
                showingAsk = true
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.bottom, 10)
        }
        .background(AtlasTheme.bg.opacity(0.01))
    }

    private var askConversationSheet: some View {
        ConversationView(
            client: session.client,
            threadId: askThreadId,
            title: selectedUnit?.name ?? "Autônomos",
            emptyPrompt: AutonomosAskContext.invite(destination: destination, vestment: vestmentForAsk),
            emptySuggestions: AutonomosAskContext.emptySuggestions(destination: destination),
            taskKind: "autonomos",
            workspace: nil,
            draft: "",
            turnFacts: { [selectedUnit, destination] _ in
                AutonomosAskContext.facts(unit: selectedUnit, destination: destination)
            },
            onThread: { askThreadId = $0 },
            hidesNavigationBack: true
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AtlasTheme.bg)
        .presentationCornerRadius(28)
    }
}
