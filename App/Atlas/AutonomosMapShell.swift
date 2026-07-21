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


/// Evolução — timeline deste Autônomo. Sem motor vinculado = ausência honesta.
struct AutonomosEvolutionView: View {
    let unit: AutonomosUnit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker("Evolução", live: unit?.paused == false)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
                if let unit {
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(28, .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .monospacedDigit()
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Evolução de \(unit.name), \(unit.ageLabel)")
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.bottom, 28)
                        .accessibilityLabel(unit.charter)
                }

                AutonomosMapChrome.section("Marcos")
                    .padding(.bottom, 12)

                Text("Ainda sem prova publicada neste Autônomo.")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Ainda sem prova publicada neste Autônomo.")

                Text("Quando o Server aceitar create, os ciclos aparecem aqui — só deste escopo.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel(
                        "Quando o Server aceitar create, os ciclos aparecem aqui — só deste escopo."
                    )
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosEvolution)
        // Contain without fused label: age header and empty proof stay landmarks.
        .accessibilityElement(children: .contain)
    }
}


/// Hub de um Autônomo do operador — presença → fato → verbo → Evolução.
/// Sem backlog de área de sistema. Sem número mentiroso.
struct AutonomosHubView: View {
    let unit: AutonomosUnit
    let onNavigate: (AutonomosDestination) -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onEnd: () -> Void

    private var vestment: LocalVestment {
        unit.paused ? .quiet : .live
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(kickerLine, live: !unit.paused)
                    .padding(.bottom, 14)
                    .accessibilityHidden(true)
                AutonomosMapChrome.heroTitle(vestment.hero)
                    .padding(.bottom, 10)
                    .accessibilityLabel("\(unit.name), \(vestment.hero), \(kickerLine)")
                    .accessibilityAddTraits(.isHeader)
                Text(unit.charter)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 28)
                    .accessibilityLabel(unit.charter)

                primaryVerb
                    .padding(.bottom, 8)

                AutonomosMapChrome.hairline
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                AutonomosMapNavLine(
                    title: "Evolução",
                    meta: "ainda sem provas",
                    action: { onNavigate(.evolution) }
                )

                if unit.paused {
                    AutonomosMapNavLine(title: "Encerrar", meta: "", danger: true, action: onEnd)
                } else {
                    // Medium: Pausar is a governed presence commit (mirrors Retomar).
                    AutonomosMapNavLine(title: "Pausar", meta: "", haptic: .medium, action: onPause)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosHub)
        // Contain: hero, charter, Retomar/nav lines stay separately focusable.
        .accessibilityElement(children: .contain)
    }

    private var kickerLine: String {
        "\(vestment.kicker) · \(unit.ageLabel)"
    }

    @ViewBuilder
    private var primaryVerb: some View {
        switch vestment {
        case .quiet:
            AutonomosMapChrome.primaryCTA("Retomar", haptic: .medium, action: onResume)
                .accessibilityHint("retoma este Autônomo a partir da pausa")
        case .live:
            EmptyView()
        }
    }

    private enum LocalVestment {
        case live
        case quiet

        var kicker: String {
            switch self {
            case .live: "Vivo"
            case .quiet: "Parado"
            }
        }

        var hero: String {
            switch self {
            case .live: "No escopo"
            case .quiet: "Em pausa"
            }
        }
    }
}


/// Lista de Autônomos do operador — índice soberano. Vazio até criar. Zero áreas de sistema.
struct AutonomosListView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let units: [AutonomosUnit]
    let onOpen: (AutonomosUnit) -> Void
    let onCreate: () -> Void

    var body: some View {
        Group {
            if units.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .accessibilityIdentifier(A11yID.autonomosList)
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(units) { unit in
                    unitRow(unit)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 140)
        }
        .scrollIndicators(.hidden)
        // Contain: each unit row stays a separate VO focus.
        .accessibilityElement(children: .contain)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 36)
            Text("✦")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            AutonomosMapChrome.heroTitle("Nenhum ainda", size: 32)
            Text("Crie um Autônomo com escopo fechado. Ele evolui só nisso — 24/7.")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityLabel(
                    "Crie um Autônomo com escopo fechado. Ele evolui só nisso, 24 por 7."
                )
            // Medium: primary entry into create flow on empty catalog.
            AutonomosMapChrome.primaryCTA("Novo Autônomo", haptic: .medium, action: onCreate)
                .accessibilityHint("abre o formulário para criar um Autônomo")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        // Contain: hero speaks as header; Novo CTA remains a separate target.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosListEmpty)
    }

    private func unitRow(_ unit: AutonomosUnit) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
                trailing(unit)
            }
            .padding(.vertical, 18)
            .frame(minHeight: 56, alignment: .top)
            .contentShape(Rectangle())
            .opacity(unit.paused ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        // Ignore children so spoken(unit) is the single VO node (no double name/charter).
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spoken(unit))
        .accessibilityHint("abre o hub deste Autônomo")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.autonomosUnit(unit.id))
    }

    @ViewBuilder
    private func trailing(_ unit: AutonomosUnit) -> some View {
        if unit.paused {
            Text("pausado")
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                .padding(.top, 6)
                // Row combine speaks "pausado"; visual UPPERCASE is decoration only.
                .accessibilityHidden(true)
        } else {
            Circle()
                .fill(AtlasTheme.accent.opacity(0.85))
                .frame(width: 5, height: 5)
                .padding(.top, 10)
                .accessibilityHidden(true)
        }
    }

    private func spoken(_ unit: AutonomosUnit) -> String {
        var parts = [unit.name, unit.charter]
        parts.append(unit.paused ? "pausado" : "vivo")
        parts.append(unit.ageLabel)
        return parts.joined(separator: ", ")
    }
}


/// Folha Novo Autônomo — nome + carta (mockup v9).
struct AutonomosNewSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name = ""
    @State private var charter = ""
    let onCreate: (String, String) -> Void
    let onCancel: () -> Void

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    AutonomosMapChrome.heroTitle("Novo Autônomo", size: 28)
                    Text("Um escopo fechado. Ele evolui só nisso.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Um escopo fechado. Ele evolui só nisso.")

                    field(
                        label: "Nome",
                        placeholder: "ex.: Agente iOS Dinheiro",
                        text: $name,
                        axis: .horizontal,
                        a11yHint: "nome curto do Autônomo",
                        a11yID: A11yID.autonomosNewName
                    )
                    field(
                        label: "Carta",
                        placeholder: "O que este Autônomo pode e não pode tocar.",
                        text: $charter,
                        axis: .vertical,
                        a11yHint: "escopo fechado em português claro",
                        a11yID: A11yID.autonomosNewCharter
                    )

                    AutonomosMapChrome.primaryCTA("Criar", enabled: canCreate, haptic: .medium) {
                        onCreate(name, charter)
                    }
                    .accessibilityHint(canCreate ? "cria o Autônomo no catálogo" : "digite um nome para criar")
                    AutonomosMapChrome.quietCTA("Cancelar", action: onCancel)
                        .accessibilityHint("fecha sem criar")
                }
                .padding(AtlasTheme.Space.screen)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg)
            .accessibilityIdentifier(A11yID.autonomosNew)
            // Contain: fields and CTAs stay separately focusable.
            .accessibilityElement(children: .contain)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis,
        a11yHint: String,
        a11yID: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
                // Visual only — TextField carries accessibilityLabel(label).
                .accessibilityHidden(true)
            Group {
                if axis == .vertical {
                    TextField(placeholder, text: text, axis: .vertical)
                        .lineLimit(3...6)
                } else {
                    TextField(placeholder, text: text)
                }
            }
            .font(AtlasFont.serif(17))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: axis == .horizontal ? 48 : 88, alignment: .topLeading)
            .background(AtlasTheme.bgRecessed, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .strokeBorder(AtlasTheme.separator.opacity(0.55), lineWidth: 1)
            )
            .accessibilityLabel(label)
            .accessibilityHint(a11yHint)
            .accessibilityIdentifier(a11yID)
        }
    }
}


/// Folha padrão de governança: quem autoriza + motivo auditável.
/// Compacta (era floresta de peels) — um arquivo, contrato de a11y estável.
struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var actor = ""
    @State private var reason: String

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

    private var canSubmit: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (reasonOptional || !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação governada") {
                    Text(title).accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") {
                    TextField("Quem autoriza", text: $actor)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint("nome de quem autoriza a ação governada")
                }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical)
                        .lineLimit(3...6)
                        .frame(minHeight: 88, alignment: .topLeading)
                        .accessibilityIdentifier(A11yID.autonomosReasonField)
                        .accessibilityHint(
                            reasonOptional
                                ? "motivo auditável opcional no ensaio"
                                : "motivo auditável registrado no ledger"
                        )
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: "Cancelar",
                        spokenLabel: "cancelar ação governada",
                        spokenHint: "fecha sem registrar recibo",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        // Medium: governed pause/end with operator receipt.
                        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                    .accessibilityLabel(
                        canSubmit
                            ? "confirmar \(title.lowercased())"
                            : "confirmar indisponível, preencha operador e motivo"
                    )
                    .accessibilityHint(
                        canSubmit
                            ? "registra operador e motivo no recibo governado"
                            : "preencha quem autoriza e o motivo"
                    )
                    .accessibilityAddTraits(.isButton)
                    .accessibilitySortPriority(canSubmit ? 9 : 0)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            // Contain without fused sheet label so fields/confirm stay focusable.
            .accessibilityElement(children: .contain)
        }
    }
}


// Cycle 044 fuse → AutonomosRhythmSheet.swift

/// "O ritmo do seu dia" — a explicação do aprender-com-o-uso. Mostra o que o
/// Atlas aprendeu (janelas do dia), o que observou hoje e o que faz com isso
/// (proposta noturna). Só afirma o que está provado no registro local (C13).
struct AutonomosRhythmSheet: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let windows: AtlasDayRhythm.Windows
    @State private var today: AtlasDayRhythm.DaySummary?
    @State private var nightly = NightlyProposalController.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("APRENDER COM O USO")
                .font(AtlasFont.mono(10, .semibold))
                .foregroundStyle(AtlasTheme.accent)
                .kerning(1.2)
            Text("O ritmo do seu dia")
                .font(AtlasFont.serif(22, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(AutonomosRhythmCopy.learnedParagraph(windows))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 6) {
                if let dayStart = AutonomosRhythmCopy.hour(windows.dayStart) {
                    rhythmRow("dia começa", "~\(dayStart)")
                }
                if let dayEnd = AutonomosRhythmCopy.hour(windows.dayEnd) {
                    rhythmRow("dia termina", "~\(dayEnd)")
                }
                rhythmRow("amostra", "\(windows.sampleDays) \(windows.sampleDays == 1 ? "dia" : "dias") de uso")
                rhythmRow("hoje", AutonomosRhythmCopy.todayLine(today))
                if let score = AutonomosRhythmCopy.scoreLine(AtlasSession.nightlyProposalScore()) {
                    rhythmRow("propostas", score)
                }
                if let adjustment = AutonomosRhythmCopy.adjustmentLine(AtlasSession.nightlyProposalAdjustmentMinutes()) {
                    rhythmRow("ajuste", adjustment)
                }
            }

            Text(AutonomosRhythmCopy.whatHappensParagraph(windows))
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if let muted = nightly.spokenMuteStatus() {
                VStack(alignment: .leading, spacing: 8) {
                    Text(muted)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Button {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        nightly.unmuteProposal()
                    } label: {
                        Text("Reativar propostas noturnas")
                            .font(AtlasFont.mono(11, .semibold))
                            .foregroundStyle(AtlasTheme.accent)
                            .frame(minHeight: 48, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("reativar propostas noturnas")
                    .accessibilityHint("volta a mostrar a proposta das 21h quando o Atlas tiver algo a dizer")
                    .accessibilityIdentifier(A11yID.autonomosRhythmUnmute)
                    .accessibilityAddTraits(.isButton)
                }
            }

            Spacer(minLength: 0)

            Text("aprendido e guardado só neste iPhone — nada sai do aparelho")
                .font(AtlasFont.mono(9.5))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(AtlasTheme.bg)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosRhythmSheet)
        .task { today = await AtlasSession.rhythm.todaySummary() }
    }

    private func rhythmRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Copy do ritmo — a linha, as falas e os parágrafos da folha. Toda afirmação
/// vem das janelas reais; aprendizado incompleto é dito como incompleto.
enum AutonomosRhythmCopy {
    static func line(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        let base: String
        if windows.sampleDays < 4 {
            base = "aprendendo seu ritmo · dia \(max(1, windows.sampleDays)) de 4"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido · seu dia termina ~\(dayEnd)"
        } else {
            base = "ritmo aprendido · \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base) · propostas em pausa" : base
    }

    static func spokenLine(_ windows: AtlasDayRhythm.Windows, paused: Bool = false) -> String {
        let base: String
        if windows.sampleDays < 4 {
            base = "aprendendo seu ritmo, dia \(max(1, windows.sampleDays)) de 4"
        } else if let dayEnd = hour(windows.dayEnd) {
            base = "ritmo aprendido: seu dia costuma terminar perto das \(dayEnd)"
        } else {
            base = "ritmo aprendido em \(windows.sampleDays) dias de uso"
        }
        return paused ? "\(base). Propostas noturnas em pausa" : base
    }

    static func learnedParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "O Atlas observa quando seu dia de trabalho começa e termina. Faltam \(4 - windows.sampleDays) \(4 - windows.sampleDays == 1 ? "dia" : "dias") para ele conhecer seu ritmo."
        }
        return "O Atlas aprendeu seu ritmo observando o uso real — a mediana dos seus últimos dias de trabalho."
    }

    static func whatHappensParagraph(_ windows: AtlasDayRhythm.Windows) -> String {
        if windows.sampleDays < 4 {
            return "Quando o ritmo estiver aprendido, no fim do seu dia o Atlas vai propor uma missão noturna — a frota continua enquanto você descansa."
        }
        return "No fim do seu dia, se houve trabalho, o Atlas propõe uma missão noturna — a frota continua enquanto você descansa, e de manhã o resultado espera por você."
    }

    static func todayLine(_ today: AtlasDayRhythm.DaySummary?) -> String {
        guard let today, !today.workspaces.isEmpty else {
            return "nenhum trabalho registrado ainda"
        }
        return today.workspaces.joined(separator: " · ")
    }

    /// Placar só existe depois da primeira resposta — zero histórico, zero linha.
    static func scoreLine(_ score: (accepted: Int, dismissed: Int)) -> String? {
        guard score.accepted + score.dismissed > 0 else { return nil }
        let aceitas = "\(score.accepted) \(score.accepted == 1 ? "aceita" : "aceitas")"
        let recusadas = "\(score.dismissed) \(score.dismissed == 1 ? "recusada" : "recusadas")"
        return "\(aceitas) · \(recusadas)"
    }

    /// Janela adaptativa só é dita quando existe — 0 min = sem linha.
    static func adjustmentLine(_ minutes: Int) -> String? {
        guard minutes > 0 else { return nil }
        return "+\(minutes) min — seu horário real de resposta"
    }

    static func hour(_ components: DateComponents?) -> String? {
        guard let hour = components?.hour else { return nil }
        return String(format: "%02d:%02d", hour, components?.minute ?? 0)
    }
}



/// Chrome tipográfico do mapa Autônomos v5 — sem cards, sem chips, sem ouro de chrome.
enum AutonomosMapChrome {
    static func kicker(_ text: String, live: Bool, alert: Bool = false) -> some View {
        HStack(spacing: 8) {
            if live || alert {
                Text(alert ? "※" : "✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(alert ? AtlasTheme.alert : AtlasTheme.accent)
                    .accessibilityHidden(true)
            }
            Text(text.uppercased())
                .font(AtlasFont.mono(10))
                .tracking(1.4)
                .foregroundStyle(alert ? AtlasTheme.alert : (live ? AtlasTheme.accent : AtlasTheme.textTertiary))
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
        // Spoken title stays natural case — uppercase tracking is visual only.
        .accessibilityLabel(text)
    }

    static func heroTitle(_ text: String, size: CGFloat = 30) -> some View {
        Text(text)
            .font(AtlasFont.serif(size, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    static var hairline: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        AtlasTheme.separator.opacity(0.12),
                        AtlasTheme.separator.opacity(0.95),
                        AtlasTheme.separator.opacity(0.12)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, 4)
            .accessibilityHidden(true)
    }

    static func section(_ text: String) -> some View {
        Text(text.uppercased())
            .font(AtlasFont.mono(10))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            // Spoken title stays natural case — uppercase tracking is visual only.
            .accessibilityLabel(text)
    }

    enum CTAHaptic {
        case soft
        case medium
    }

    @MainActor
    static func primaryCTA(
        _ title: String,
        enabled: Bool = true,
        haptic: CTAHaptic = .soft,
        action: @escaping () -> Void
    ) -> some View {
        AutonomosMapPrimaryCTA(title: title, enabled: enabled, haptic: haptic, action: action)
    }

    @MainActor
    static func quietCTA(_ title: String, danger: Bool = false, action: @escaping () -> Void) -> some View {
        AutonomosMapQuietCTA(title: title, danger: danger, action: action)
    }
}

/// Primary map CTA — Environment Reduce Motion (not UIAccessibility global).
private struct AutonomosMapPrimaryCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var enabled: Bool = true
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            if enabled {
                switch haptic {
                case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
                case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                }
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14, .medium)
                .foregroundStyle(AtlasTheme.textPrimary.opacity(enabled ? 1 : 0.35))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .background(AtlasTheme.textPrimary.opacity(enabled ? 0.055 : 0.03), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(enabled ? 0.1 : 0.04), lineWidth: 1))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(enabled ? "confirma \(title.lowercased())" : "indisponível"))
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(enabled ? 9 : 0) // primary map CTA surfaces early in VO
    }
}

private struct AutonomosMapQuietCTA: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            // Soft invitation; medium when danger (governed destructive quiet CTA).
            if danger {
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            } else {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            Text(title)
                .atlasSans(14)
                .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .overlay(
                    Capsule().strokeBorder(
                        danger ? AtlasTheme.alert.opacity(0.35) : AtlasTheme.separator.opacity(0.7),
                        lineWidth: 1
                    )
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(danger ? "ação destrutiva" : "ação secundária, \(title.lowercased())"))
        .accessibilityAddTraits(.isButton)
    }
}

// Cycle 046 fused AutonomosChrome+Buttons.swift

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .frame(minHeight: 48) // HIG 44+; match primary map CTA breath
            .background(
                Capsule().fill(
                    AtlasTheme.accent.opacity(
                        configuration.isPressed && !reduceMotion ? 0.72 : 1
                    )
                )
            )
            .contentShape(Capsule())
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }
}


/// Linha › do mapa Autônomos — tipografia, sem cápsula.
struct AutonomosMapNavLine: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let title: String
    let meta: String
    var danger: Bool = false
    /// Soft default (nav); medium for governed state commits (e.g. Pausar).
    var haptic: AutonomosMapChrome.CTAHaptic = .soft
    let action: () -> Void

    var body: some View {
        Button {
            switch haptic {
            case .soft: AtlasMotion.softImpact(reduceMotion: reduceMotion)
            case .medium: AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            }
            action()
        } label: {
            HStack(spacing: 10) {
                Text(title)
                    .atlasSans(15.5, .medium)
                    .foregroundStyle(danger ? AtlasTheme.alert : AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !meta.isEmpty {
                    Text(meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Text("›")
                    .atlasSans(13)
                    .foregroundStyle(danger ? AtlasTheme.alert.opacity(0.7) : AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, 14)
            .frame(minHeight: 48, alignment: .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline.padding(.vertical, 0) }
        .accessibilityLabel(meta.isEmpty ? title : "\(title), \(meta)")
        .accessibilityHint(danger ? "abre confirmação de \(title.lowercased())" : "abre \(title.lowercased())")
        .accessibilityAddTraits(.isButton)
        // Medium governed (Pausar) and danger (Encerrar) surface early in VO.
        .accessibilitySortPriority(haptic == .medium || danger ? 8 : 0)
        .accessibilityIdentifier(A11yID.autonomosNav(title))
    }
}
