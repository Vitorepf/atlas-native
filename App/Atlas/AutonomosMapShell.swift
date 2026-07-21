import SwiftUI
import AtlasCore
import Foundation

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
        // Contain: catalog vs hub/evolution remain separately focusable destinations.
        .accessibilityElement(children: .contain)
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
            if let error = model.controlError {
                controlErrorBanner(error)
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
        // Contain: banner, rhythm, list/empty stay separately focusable.
        .accessibilityElement(children: .contain)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
    }

    /// Falha honesta do dry-run / load — nunca some o erro em silêncio.
    private func controlErrorBanner(_ error: String) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            model.controlError = nil
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .atlasSans(14, .semibold)
                    .foregroundStyle(AtlasTheme.alert)
                    .accessibilityHidden(true)
                Text(error)
                    .font(AtlasFont.serif(14))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 12)
            .frame(minHeight: 48)
            .contentShape(Rectangle())
            .background(AtlasTheme.alert.opacity(0.08))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(error)
        .accessibilityHint("toque para dispensar")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosControlError)
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


// Linha de ritmo — autossuficiente: lê as janelas aprendidas do AtlasDayRhythm
// e abre a folha "O ritmo do seu dia" ao toque. O aprendizado não some quando
// completa: a linha amadurece e passa a dizer o que foi aprendido.
// Sheet → AutonomosRhythmSheet.swift · Copy → AutonomosRhythmSheet+Copy.swift

struct AutonomosRhythmLearningLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Placeholder até o actor devolver as janelas reais — a linha existe
    /// imediatamente (UITest + layout estáveis).
    @State private var windows = AtlasDayRhythm.Windows(dayEnd: nil, dayStart: nil, sampleDays: 0)
    @State private var rhythmSheetShown = false
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            rhythmSheetShown = true
        } label: {
            HStack(spacing: 5) {
                Text(AutonomosRhythmCopy.line(windows, paused: nightly.isProposalMuted))
                    .font(AtlasFont.mono(10))
                    .lineLimit(2)
                Image(systemName: "chevron.right")
                    .atlasSans(7, .semibold)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosRhythmCopy.spokenLine(windows, paused: nightly.isProposalMuted))
        .accessibilityHint("mostra o que o Atlas aprendeu do seu dia")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosRhythmLine)
        .sheet(isPresented: $rhythmSheetShown) {
            AutonomosRhythmSheet(windows: windows)
        }
        .task { windows = await AtlasSession.rhythm.windows(minimumDays: 4) }
    }
}


/// Pack de contexto Autônomos v9 — presentation-only; pack nunca na cara.
enum AutonomosAskContext {
    static func invite(destination: AutonomosDestination?, vestment: AutonomosHubVestment) -> String {
        switch destination {
        case .evolution:
            return "resuma isto"
        case .hub:
            break
        case nil:
            return "o que mudou hoje?"
        }
        switch vestment {
        case .live: return "o que ele fez hoje?"
        case .quiet: return "devo retomar?"
        }
    }

    static func emptySuggestions(destination: AutonomosDestination?) -> [String] {
        switch destination {
        case .evolution:
            return ["o que mudou hoje?", "o que ele melhorou?"]
        case .hub:
            return ["devo retomar?", "o que ele fez?"]
        case nil:
            return ["novo Autônomo", "o que mudou hoje?"]
        }
    }

    static func facts(unit: AutonomosUnit?, destination: AutonomosDestination?) -> String {
        var lines: [String] = [
            "Contexto Autônomos (ocasião). Pack local anexa sempre; intenção do operador pode pedir outro mundo — não bloqueie por silo.",
        ]
        if let unit {
            lines.append("Autônomo: \(unit.name).")
            lines.append("Carta: \(unit.charter)")
            lines.append(unit.paused ? "Estado: pausado." : "Estado: vivo no escopo local.")
            lines.append("Idade: \(unit.ageLabel).")
        } else {
            lines.append("Lista de Autônomos — nenhum aberto.")
        }
        if let destination {
            lines.append("Tela: \(destination.navTitle).")
        }
        lines.append("Create Server de Autônomo ainda pendente (§5); catálogo local pode sumir no kill do app.")
        lines.append("Pause/retomar/encerrar: controles da face; NL de chat ainda não autoriza tools de escrita no wire.")
        lines.append("Transfer/decide do motor não têm face nesta versão — não invente recibos de transferência.")
        return lines.joined(separator: "\n")
    }
}
