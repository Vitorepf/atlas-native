import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: Autonomos host surfaces fused (file not route shell density)

// MARK: - AutonomosView

// MARK: - View

// MARK: - Host

struct AutonomosView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var destination: AutonomosDestination?
    @State var selectedUnitID: String?
    @State var showNewSheet = false

    var model: AutonomosModel { session.autonomos }

    var body: some View {
        autonomosLifecycleChrome(
            ZStack {
                AtlasTheme.bg.ignoresSafeArea()
                autonomosHeaderStack
            }
        )
    }
}

extension AutonomosView {
    @ViewBuilder
    var autonomosBusyPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading:
            loadingContent
        case .failed(let message):
            failedContent(message: message)
        default:
            EmptyView()
        }
    }
}

// MARK: - Sections

extension AutonomosView {
    @ViewBuilder
    var autonomosPhaseRouter: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            autonomosBusyPhaseRouter
        case .loaded:
            loadedContent
        }
    }
}

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        autonomosPhaseRouter
    }
}

extension AutonomosView {
    func failedContent(message: String) -> some View {
        VStack {
            Spacer()
            AutonomosFleetFailureEmpty(message: message) {
                Task { await model.load() }
            }
            Spacer()
        }
    }
}

extension AutonomosView {
    var loadedContent: some View {
        AutonomosMapShell(
            model: model,
            destination: $destination,
            selectedUnitID: $selectedUnitID,
            showNewSheet: $showNewSheet
        )
    }
}

extension AutonomosView {
    var loadingContent: some View {
        VStack {
            Spacer()
            TraceEvidenceLoading(text: "abrindo catálogo…", reduceMotion: reduceMotion)
            Spacer()
        }
    }
}

extension AutonomosView {
    var autonomosContentAnimated: some View {
        content
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
    }
}

extension AutonomosView {
    var autonomosHeaderStack: some View {
        VStack(spacing: 0) {
            AutonomosViewHeader(
                auditModeEnabled: session.auditModeEnabled,
                canRefresh: false,
                isHealthy: isHeaderHealthy,
                title: headerTitle,
                subtitle: headerSubtitle,
                subtitleLive: headerSubtitleLive,
                trailing: destination == nil ? .create : .none,
                reduceMotion: reduceMotion,
                onBack: {
                    if let destination {
                        self.destination = destination.backTarget
                        if self.destination == nil {
                            selectedUnitID = nil
                        }
                    } else {
                        dismiss()
                    }
                },
                onRefresh: {},
                onCreate: {
                    showNewSheet = true
                }
            )
            autonomosContentAnimated
        }
    }

    private var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    private var headerTitle: String {
        guard let destination else { return "Autônomos" }
        if case .hub = destination {
            return selectedUnit?.name ?? "Autônomo"
        }
        return destination.navTitle
    }

    private var headerSubtitle: String {
        guard let destination else { return "" }
        switch destination {
        case .hub:
            // WAVE-030: loop face when area bound; else catalog pause honesty.
            if model.selectedArea != nil {
                return AutonomosRunControlJudgment.face(
                    areaSelected: true,
                    canControl: model.canControlSelectedArea,
                    live: model.live
                ).productWord
            }
            guard let unit = selectedUnit else { return "" }
            return unit.paused ? "Parado" : "Vivo"
        case .evolution:
            return selectedUnit?.name ?? ""
        case .decisions, .decisionInbox, .decisionOrder:
            let face = AutonomosDecisionJudgment.face(
                backlog: model.backlog,
                areaSelected: model.selectedArea != nil,
                error: model.controlError
            )
            return face.productWord
        default:
            return ""
        }
    }

    private var headerSubtitleLive: Bool {
        guard let destination else { return false }
        switch destination {
        case .hub, .evolution:
            return selectedUnit.map { !$0.paused } ?? false
        case .decisions, .decisionInbox, .decisionOrder:
            if case .items = AutonomosDecisionJudgment.face(
                backlog: model.backlog,
                areaSelected: model.selectedArea != nil,
                error: model.controlError
            ) { return true }
            return false
        default:
            return false
        }
    }
}

// MARK: - Chrome

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(AtlasFont.serif(13, .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(
                Capsule().fill(
                    AtlasTheme.accent.opacity(
                        configuration.isPressed && !reduceMotion ? 0.72 : 1
                    )
                )
            )
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
// MARK: - AutonomosViewHeader

extension AutonomosViewHeader {
    func spokenTitle(isHealthy: Bool, auditModeEnabled: Bool) -> String {
        var parts = [title, subtitle]
        if auditModeEnabled { parts.append("modo auditoria") }
        return parts.joined(separator: ", ")
    }

    func spokenBackLabel() -> String { WorkspaceJudgment.backLabel }

    func spokenBackHint() -> String { "volta" }
}

extension AutonomosViewHeader {
    func spokenRefreshLabel(canRefresh: Bool) -> String {
        canRefresh
            ? "atualizar instância selecionada"
            : "atualizar indisponível, selecione uma instância"
    }

    func spokenRefreshHint(canRefresh: Bool) -> String {
        canRefresh ? "recarrega estado da área selecionada" : "nenhuma instância selecionada"
    }
}

extension AutonomosViewHeader {
    var backButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel(spokenBackLabel())
        .accessibilityHint(spokenBackHint())
        .accessibilityIdentifier(A11yID.autonomosBack)
    }
}

extension AutonomosViewHeader {
    var createButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onCreate()
        } label: {
            Image(systemName: "plus")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel(AutonomosListJudgment.createCTA)
        .accessibilityHint("Cria um Autônomo com nome e carta")
        .accessibilityIdentifier(A11yID.autonomosNew)
    }
}

extension AutonomosViewHeader {
    var headerLayout: some View {
        HStack(spacing: 12) {
            backButton
            titleBlock
            Spacer()
            trailingButton
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .create:
            createButton
        case .refresh:
            refreshButton
        }
    }
}

extension AutonomosViewHeader {
    var refreshButton: some View {
        Button {
            if canRefresh { AtlasMotion.softImpact(reduceMotion: reduceMotion) }
            onRefresh()
        } label: {
            Image(systemName: "arrow.clockwise")
                .atlasSans(15, .medium)
                .foregroundStyle(canRefresh ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .disabled(!canRefresh)
        .opacity(canRefresh ? 1 : 0.45)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: canRefresh)
        .accessibilityLabel(spokenRefreshLabel(canRefresh: canRefresh))
        .accessibilityHint(spokenRefreshHint(canRefresh: canRefresh))
        .accessibilityIdentifier(A11yID.autonomosRefresh)
    }
}

extension AutonomosViewHeader {
    var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            titleBadges
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenTitle(isHealthy: isHealthy, auditModeEnabled: auditModeEnabled))
        .accessibilityIdentifier(A11yID.autonomosHeader)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
    }
}
// MARK: - AutonomosSurface

extension AutonomosView {
    /// Face = catálogo local; masthead quieto (sem frota/backlog de sistema).
    var isHeaderHealthy: Bool { true }
}

extension AutonomosView {
    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        default: return nil
        }
    }
}

extension AutonomosView {
    var contentPhaseID: String {
        if let busy = contentPhaseBusyID { return busy }
        switch model.phase {
        case .loaded: return "loaded"
        case .failed: return "failed"
        default: return "idle"
        }
    }
}

extension AutonomosView {
    func spokenScreenBusyLabel() -> String? {
        switch model.phase {
        case .idle, .loading:
            return "Autônomos, abrindo catálogo"
        case .failed:
            return "Autônomos, falha ao abrir catálogo"
        default:
            return nil
        }
    }
}

extension AutonomosView {
    func spokenScreenPhaseLabel() -> String {
        if let busy = spokenScreenBusyLabel() { return busy }
        if isHeaderHealthy {
            return "Autônomos, catálogo quieto"
        }
        return "Autônomos, catálogo carregado"
    }
}

extension AutonomosView {
    func spokenScreenLabel() -> String {
        spokenScreenPhaseLabel()
    }

    static let screenHint = "catálogo local neste iPhone; pergunta e manda só pela pílula"
}

struct AutonomosFleetFailureEmpty: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        AtlasOpsFailureEmpty(
            mode: .load(headline: "Catálogo fora de alcance.", message: message),
            layout: .centered,
            symbol: "exclamationmark.triangle",
            topPadding: 0,
            accessibilityIdentifier: A11yID.autonomosLoadFailure,
            retryAccessibilityIdentifier: A11yID.autonomosRetry,
            retryHint: "tenta reabrir o catálogo Autônomos",
            spokenOverride: "Catálogo Autônomos fora de alcance. \(message)",
            onRetry: onRetry
        )
        .padding(32)
    }
}

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosLifecycleScreenA11y(content)
    }
}

extension AutonomosView {
    func autonomosLifecycleScreenA11y<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            // children:.contain — NÃO colapsar o ecrã num único label; Nightly/
            // Ritmo/lista precisam de identifiers próprios na árvore a11y.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.autonomosScreen)
            .task { await model.load() }
    }
}

extension AutonomosViewHeader {
    @ViewBuilder
    var titleBadges: some View {
        if !subtitle.isEmpty {
            Text(subtitle.uppercased())
                .font(AtlasFont.mono(10)).tracking(1.2)
                .foregroundStyle(subtitleLive ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        }
        if auditModeEnabled {
            Text("MODO AUDITORIA")
                .font(AtlasFont.mono(9)).tracking(1.0)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        }
    }
}

struct AutonomosViewHeader: View {
    enum Trailing {
        case none
        case refresh
        case create
    }

    let auditModeEnabled: Bool
    let canRefresh: Bool
    let isHealthy: Bool
    var title: String = "Autônomos"
    var subtitle: String = ""
    var subtitleLive: Bool = false
    var trailing: Trailing = .refresh
    let reduceMotion: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void
    var onCreate: () -> Void = {}

    var body: some View {
        headerLayout
    }
}
// MARK: - AutonomosListView

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
// MARK: - AutonomosDigestSurface

// MARK: - Digest / moment surface (WAVE-038)

/// One domain: scheduled digest window → delivered · risks · pending.
struct AutonomosDigestSurface: View {
    let digest: AtlasAutonomosDigestResponse?

    private var face: AutonomosDigestFace {
        AutonomosDigestJudgment.face(from: digest)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(
                    face.productWord,
                    live: face.productWord == "attention"
                )
                .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
                    .padding(.bottom, 8)

                if let digest {
                    digestBody(digest)
                } else {
                    Text("Digest não publicado neste recorte. Nada inventado.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel(face.spokenFace)
    }

    @ViewBuilder
    private func digestBody(_ digest: AtlasAutonomosDigestResponse) -> some View {
        Text(AutonomosDigestJudgment.windowLine(digest))
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 6)
        Text(AutonomosDigestJudgment.countsLine(digest))
            .font(AtlasFont.serif(16, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.bottom, 8)
        if let schedule = AutonomosDigestJudgment.scheduleLine(digest) {
            Text(schedule)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .padding(.bottom, 18)
        }

        let pending = AutonomosDigestJudgment.rankPending(digest.last.pendingDecisions)
        if !pending.isEmpty {
            sectionHeader("Decisões na janela")
            ForEach(pending) { item in
                row(
                    title: item.title,
                    meta: "\(item.severity) · prio \(item.priorityScore) · \(item.route)",
                    accent: true
                )
            }
        }

        let risks = AutonomosDigestJudgment.rankRisks(digest.last.risks)
        if !risks.isEmpty {
            sectionHeader("Riscos")
            ForEach(risks) { risk in
                row(
                    title: risk.title ?? risk.reason ?? "Risco \(risk.severity)",
                    meta: "\(risk.severity)\(risk.route.map { " · \($0)" } ?? "")",
                    accent: risk.severity.lowercased().contains("high")
                        || risk.severity.lowercased().contains("crit")
                )
            }
        }

        let delivered = AutonomosDigestJudgment.rankDelivered(digest.last.delivered)
        if !delivered.isEmpty {
            sectionHeader("Entregas")
            ForEach(delivered) { d in
                row(
                    title: "Ciclo \(d.cycleIndex) · \(d.outcome)",
                    meta: "\(d.cycleFinalStatus)\(d.mergePerformed ? " · merge" : "") · \(d.recordedAt)",
                    accent: d.mergePerformed
                )
            }
        }

        if pending.isEmpty && risks.isEmpty && delivered.isEmpty {
            Text("Janela sem itens publicados. Silêncio honesto.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 8)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        AutonomosMapChrome.section(title)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    private func row(title: String, meta: String, accent: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(meta)
                .font(AtlasFont.mono(11))
                .foregroundStyle(accent ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosDigestJudgment.spokenRow(title: title, meta: meta))
    }
}
// MARK: - AutonomosIncidentSurface

// MARK: - Incident / task-health surface (WAVE-036)

/// One domain: published task health → incident/pressure/quiet faces.
struct AutonomosIncidentSurface: View {
    let areaSelected: Bool
    let health: AtlasAutonomosTaskHealthResponse?

    private var face: AutonomosTaskHealthFace {
        AutonomosTaskHealthJudgment.face(areaSelected: areaSelected, health: health)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker(
                    face.productWord,
                    live: face.productWord == "incident" || face.productWord == "pressure"
                )
                .padding(.bottom, 14)
                AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
                    .padding(.bottom, 8)
                Text(face.heroSub)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 22)

                if let health {
                    healthBody(health)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(
            face.productWord == "incident"
                ? A11yID.autonomosTaskHealthIncident
                : A11yID.autonomosTaskHealthQuiet
        )
        .accessibilityLabel(face.spokenFace)
    }

    @ViewBuilder
    private func healthBody(_ health: AtlasAutonomosTaskHealthResponse) -> some View {
        AutonomosMapChrome.section("Operação")
            .padding(.bottom, 10)
        Text(AutonomosTaskHealthJudgment.operatingLine(health))
            .font(AtlasFont.serif(16, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 18)

        AutonomosMapChrome.section("Fila")
            .padding(.bottom, 10)
        Text(AutonomosTaskHealthJudgment.tasksSummary(health))
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
        Text("leases ativos \(health.leases.active)· match claimed \(health.leases.matchesClaimed ? "sim" : "não")")
            .font(AtlasFont.mono(11))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.bottom, 18)

        let flags = AutonomosTaskHealthJudgment.flagLines(health)
        if !flags.isEmpty {
            AutonomosMapChrome.section("Sinais")
                .padding(.bottom, 10)
            ForEach(Array(flags.enumerated()), id: \.offset) { _, flag in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(AtlasTheme.domOperacional.opacity(0.85))
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)
                    Text(flag)
                        .font(AtlasFont.serif(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(AutonomosTaskHealthJudgment.spokenSignal(flag))
            }
        } else if face.productWord == "quiet" {
            Text("Nenhum flag de incidente neste recorte.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textTertiary)
        }

        Text("observado \(health.observedAt)")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .padding(.top, 20)
            .accessibilityLabel(AutonomosTaskHealthJudgment.spokenObservedAt(health.observedAt))
    }
}
// MARK: - AutonomosEvolutionView

struct AutonomosEvolutionView: View {
    let unit: AutonomosUnit?
    let areaSelected: Bool
    let delivered: AtlasAutonomosDeliveredResponse?
    let cycles: AtlasAutonomosCyclesResponse?
    let onOpenReceipt: (SelfConstructionReceipt) -> Void

    private var marcos: [AutonomosEvolutionMarco] {
        AutonomosEvolutionJudgment.marcos(delivered: delivered, cycles: cycles)
    }

    private var face: AutonomosEvolutionFace {
        AutonomosEvolutionJudgment.face(areaSelected: areaSelected, marcos: marcos)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                AutonomosMapChrome.kicker("Evolução", live: face.productWord == "delivered")
                    .padding(.bottom, 14)

                if let unit {
                    Text(unit.ageLabel)
                        .font(AtlasFont.mono(28, .semibold))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .monospacedDigit()
                        .padding(.bottom, 8)
                    Text(unit.charter)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.bottom, 20)
                }

                Text(face.spokenFace)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 8)
                Text(face.heroSub)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)

                switch face {
                case .unbound, .empty:
                    emptyBlock
                case .items:
                    AutonomosMapChrome.section("Marcos")
                        .padding(.bottom, 12)
                    ForEach(marcos) { marco in
                        marcoRow(marco)
                    }
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 16)
            .padding(.bottom, 140)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .scrollIndicators(.hidden)
        .accessibilityIdentifier(A11yID.autonomosEvolution)
        .accessibilityLabel(face.spokenFace)
    }

    private var emptyBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosMapChrome.section("Marcos")
            Text(face.heroSub)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func marcoRow(_ marco: AutonomosEvolutionMarco) -> some View {
        Button {
            guard marco.mergeProved else { return }
            onOpenReceipt(SelfConstructionReceipt(cycle: marco.cycle, finding: nil))
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(marco.title)
                        .font(AtlasFont.serif(17, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(marco.meta)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                if marco.mergeProved {
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 16)
            .opacity(marco.mergeProved ? 1 : 0.72)
        }
        .buttonStyle(.plain)
        .disabled(!marco.mergeProved)
        .overlay(alignment: .bottom) { AutonomosMapChrome.hairline }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosEvolutionJudgment.spokenMarco(title: marco.title, meta: marco.meta))
        .accessibilityHint(AutonomosEvolutionJudgment.marcoHint(mergeProved: marco.mergeProved))
    }
}

// MARK: - Area bind chooser

struct AutonomosAreaBindChooser: View {
    let areas: [AtlasAutonomosArea]
    let onSelect: (String) -> Void
    let onCancel: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ranked: [AtlasAutonomosArea] {
        AutonomosAreaBindJudgment.rankForChooser(areas)
    }

    var body: some View {
        NavigationStack {
            Group {
                if ranked.isEmpty {
                    emptySilence
                } else {
                    areaList
                }
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Área do loop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar escolha de área",
                        spokenHint: "volta sem ligar área",
                        reduceMotion: reduceMotion
                    ) { onCancel() }
                }
            }
            .accessibilityIdentifier(A11yID.autonomosAreasSheet)
            .accessibilityLabel(
                AutonomosAreaBindJudgment.spokenChooser(count: ranked.count)
            )
            .accessibilityValue(AutonomosAreaBindFace.needsBind(ranked.count).productWord)
            .accessibilityHint(AutonomosAreaBindJudgment.chooserHint)
        }
    }

    private var emptySilence: some View {
        VStack(spacing: 12) {
            Text("Nenhuma área registrada")
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("O motor não publicou áreas controláveis neste recorte.")
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosAreaBindFace.none.spokenFace)
    }

    private var areaList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(AutonomosAreaBindJudgment.chooserHint)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .accessibilityHidden(true)

                ForEach(Array(ranked.enumerated()), id: \.element.id) { index, area in
                    if index > 0 {
                        Rectangle()
                            .fill(AtlasTheme.separator.opacity(0.55))
                            .frame(height: 1)
                            .padding(.horizontal, AtlasTheme.Space.screen)
                    }
                    areaRow(area, index: index)
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func areaRow(_ area: AtlasAutonomosArea, index: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSelect(area.id)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(area.areaName.isEmpty ? area.id : area.areaName)
                    .font(AtlasFont.serif(17, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !area.focus.isEmpty {
                    Text(area.focus)
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosAreaBindJudgment.spokenChooserRow(area))
        .accessibilityHint("liga o loop a esta área")
        .accessibilityIdentifier(A11yID.autonomosAreaBindRow(area.id))
    }
}

// MARK: - Hub CTA strip

struct AutonomosAreaBindCTA: View {
    let registeredCount: Int
    let onChoose: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onChoose()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.grid.2x2")
                    .atlasSans(14, .semibold)
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(AutonomosAreaBindJudgment.ctaTitle)
                        .font(AtlasFont.mono(12, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("\(registeredCount) áreas registradas — sem área o hub fica quieto")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .atlasSans(12, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.55)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(AutonomosAreaBindJudgment.ctaSpoken)
        .accessibilityHint(AutonomosAreaBindJudgment.chooserHint)
        .accessibilityValue(AutonomosAreaBindFace.needsBind(registeredCount).productWord)
        .accessibilityIdentifier(A11yID.autonomosAreaBindCTA)
    }
}

// MARK: - AutonomosHubView

// MARK: - Hub

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

// MARK: - Vestment

enum AutonomosHubVestment: Equatable {
    case awaiting(Int)
    case live
    case quiet

    /// Precedência (WAVE-007): awaiting (decisões reais) → quiet se pause local sem live/incident
    /// → resolve server signals → quiet.
    static func resolve(
        backlog: AtlasAutonomosBacklogResponse?,
        live: AtlasAutonomosLiveResponse?,
        incidentPresent: Bool,
        unitPaused: Bool = false
    ) -> AutonomosHubVestment {
        let decisions: Int = {
            guard let backlog else { return 0 }
            return backlog.inboxItems.filter(\.decisionRequired).count
                + backlog.workOrders.filter(\.operatorDecisionRequired).count
        }()
        if decisions > 0 { return .awaiting(decisions) }
        if unitPaused, live?.isRunning != true, !incidentPresent {
            return .quiet
        }
        if live?.isRunning == true { return .live }
        if incidentPresent { return .live }
        return .quiet
    }

    var kicker: String {
        switch self {
        case .awaiting: "Pede você"
        case .live: "Vivo"
        case .quiet: "Parado"
        }
    }

    var kickerLive: Bool {
        switch self {
        case .awaiting, .live: true
        case .quiet: false
        }
    }

    var heroTitle: String {
        switch self {
        case .awaiting(let n):
            return n == 1 ? "1 decisão" : "\(n) decisões"
        case .live:
            return "Evoluindo"
        case .quiet:
            return "Em pausa"
        }
    }

    var heroSub: String {
        switch self {
        case .awaiting:
            return "Só o julgamento desbloqueia."
        case .live:
            return "Nada pede você."
        case .quiet:
            return "Por você."
        }
    }

    var navSubtitle: String {
        switch self {
        case .awaiting: "Pede você"
        case .live: "Vivo"
        case .quiet: "Parado"
        }
    }

    /// WAVE-025 product face word (align with presence vocabulary style).
    var productWord: String {
        switch self {
        case .awaiting: return "awaiting"
        case .live: return "live"
        case .quiet: return "quiet"
        }
    }

    var spokenFace: String {
        switch self {
        case .awaiting(let n):
            return n == 1 ? "pede 1 decisão" : "pede \(n) decisões"
        case .live:
            return "vivo"
        case .quiet:
            return "parado"
        }
    }

    /// List index (no backlog wire): pause local → quiet; else live catalog.
    static func listFace(unitPaused: Bool) -> AutonomosHubVestment {
        unitPaused ? .quiet : .live
    }
}

// MARK: - AutonomosDecisionSurface

// MARK: - Surface

/// Decisions organ (WAVE-026) — one domain: published backlog → face → decide.
/// WAVE-156 density peel — host (list/detail/sections peels).
struct AutonomosDecisionSurface: View {
    let model: AutonomosModel
    let destination: AutonomosDestination
    let onNavigate: (AutonomosDestination) -> Void

    @State var pendingDecision: PendingDecision?

    var face: AutonomosDecisionFace {
        AutonomosDecisionJudgment.face(
            backlog: model.backlog,
            areaSelected: model.selectedArea != nil,
            error: model.controlError
        )
    }

    var items: [AutonomosDecisionItem] {
        AutonomosDecisionJudgment.items(from: model.backlog)
    }

    var body: some View {
        Group {
            switch destination {
            case .decisionInbox, .decisionOrder:
                detailBody
            default:
                listBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier(A11yID.autonomosDecisions)
        .sheet(item: $pendingDecision) { pending in
            AutonomosReasonSheet(
                title: AutonomosDecisionJudgment.decisionLabel(pending.decision),
                explainer: pending.explainer,
                reasonOptional: !pending.requiresRationale
            ) { actor, reason in
                Task {
                    await model.decide(
                        pending.decision,
                        findingHash: pending.item.findingHash,
                        operatorActor: actor,
                        rationale: reason,
                        riskLevel: AutonomosDecisionJudgment.riskLevel(from: pending.item.riskLevel),
                        inboxItemId: pending.item.inboxItemId,
                        workOrderId: pending.item.workOrderId
                    )
                }
            }
        }
        .task(id: model.selectedAreaID) {
            guard model.selectedAreaID != nil else { return }
            await model.refreshSelected()
        }
    }
}

// MARK: - Pending decision sheet state

struct PendingDecision: Identifiable {
    let item: AutonomosDecisionItem
    let decision: AtlasAutonomosOperatorDecision
    let requiresRationale: Bool

    var id: String { "\(item.id)|\(decision.rawValue)" }

    var explainer: String {
        "Registra \(AutonomosDecisionJudgment.decisionLabel(decision).lowercased()) sobre «\(item.title)». Não inicia execução sozinho — só o julgamento do operador."
    }
}
// MARK: - AutonomosDecisionFaceBody

extension AutonomosDecisionSurface {
    // MARK: - Sections

    func faceChrome(_ face: AutonomosDecisionFace) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            faceHeader(face)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosDecisionJudgment.spokenFaceChrome(face))
    }

    func faceHeader(_ face: AutonomosDecisionFace) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosMapChrome.kicker(
                face.productWord,
                live: face.productWord == "awaiting"
            )
            AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
            Text(face.heroSub)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func decisionRow(_ item: AutonomosDecisionItem) -> some View {
        Button {
            onNavigate(item.destination)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(AtlasFont.serif(18, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(AutonomosDecisionJudgment.rowMeta(item))
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .atlasSans(13, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 6)
            }
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosDecisionJudgment.spokenItem(item))
        .accessibilityHint("abre o julgamento desta decisão")
        .accessibilityIdentifier("\(A11yID.autonomosDecision)-\(item.id)")
    }

    func receiptLine(_ receipt: AtlasAutonomosOperatorDecisionReceipt) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recibo · \(AutonomosDecisionJudgment.decisionLabel(receipt.decision))")
                .font(AtlasFont.serif(14, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(
                receipt.isRecordedDecisionOnly
                    ? "Decisão gravada · sem execução automática"
                    : "Recibo publicado · \(receipt.nextAllowedAction)"
            )
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AtlasTheme.surface.opacity(0.55))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "recibo \(AutonomosDecisionJudgment.decisionLabel(receipt.decision)), \(receipt.isRecordedDecisionOnly ? "decisão gravada sem execução" : receipt.nextAllowedAction)"
        )
    }

    func decisionMeta(
        _ decision: AtlasAutonomosOperatorDecision,
        item: AutonomosDecisionItem
    ) -> String {
        if decision == .accept,
           AutonomosDecisionJudgment.riskRequiresRationale(
            AutonomosDecisionJudgment.riskLevel(from: item.riskLevel)
           ) {
            return "exige motivo"
        }
        return ""
    }
}
// MARK: - AutonomosDecisionListBody

extension AutonomosDecisionSurface {
    // MARK: - List

    @ViewBuilder
    var listBody: some View {
        switch face {
        case .loading:
            faceChrome(face)
        case .failed:
            faceChrome(face)
        case .empty:
            faceChrome(face)
        case .items:
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    faceHeader(face)
                        .padding(.bottom, 18)
                    if let error = model.controlError, !error.isEmpty {
                        Text(error)
                            .font(AtlasFont.serifItalic(14))
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 12)
                            .accessibilityIdentifier(A11yID.autonomosControlError)
                    }
                    if let receipt = model.lastDecisionReceipt {
                        receiptLine(receipt)
                            .padding(.bottom, 14)
                    }
                    ForEach(items) { item in
                        decisionRow(item)
                    }
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .accessibilityLabel(face.spokenFace)
        }
    }
}
// MARK: - AutonomosDecisionDetailBody

extension AutonomosDecisionSurface {
    // MARK: - Detail

    @ViewBuilder
    var detailBody: some View {
        if let item = AutonomosDecisionJudgment.item(
            matching: destination,
            in: model.backlog
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    AutonomosMapChrome.kicker("Decisão · \(item.kind == .inbox ? "inbox" : "ordem")", live: true)
                        .padding(.bottom, 14)
                    AutonomosMapChrome.heroTitle(item.title, size: 28)
                        .padding(.bottom, 8)
                    Text(AutonomosDecisionJudgment.rowMeta(item))
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.bottom, 20)

                    if let error = model.controlError, !error.isEmpty {
                        Text(error)
                            .font(AtlasFont.serifItalic(14))
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 12)
                            .accessibilityIdentifier(A11yID.autonomosControlError)
                    }

                    if let receipt = model.lastDecisionReceipt,
                       receipt.findingHash == item.findingHash {
                        receiptLine(receipt)
                            .padding(.bottom, 14)
                    }

                    Text("Julgamento")
                        .font(AtlasFont.mono(10))
                        .tracking(0.8)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .textCase(.uppercase)
                        .padding(.bottom, 10)

                    ForEach(AutonomosDecisionJudgment.allowedDecisions(for: item), id: \.id) { decision in
                        AutonomosMapNavLine(
                            title: AutonomosDecisionJudgment.decisionLabel(decision),
                            meta: decisionMeta(decision, item: item),
                            action: {
                                pendingDecision = PendingDecision(
                                    item: item,
                                    decision: decision,
                                    requiresRationale: decision == .accept
                                        && AutonomosDecisionJudgment.riskRequiresRationale(
                                            AutonomosDecisionJudgment.riskLevel(from: item.riskLevel)
                                        )
                                )
                            }
                        )
                    }

                    AutonomosMapChrome.hairline
                        .padding(.vertical, 12)
                    AutonomosMapNavLine(
                        title: "Todas as decisões",
                        meta: "",
                        action: { onNavigate(.decisions) }
                    )
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier(A11yID.autonomosDecision)
            .accessibilityLabel(AutonomosDecisionJudgment.spokenItem(item))
        } else {
            // Item vanished after decide or was never published — silence, not theater.
            faceChrome(.empty)
        }
    }
}

// MARK: - AutonomosSheets

// MARK: - New sheet

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
                    Text("Um escopo fechado. Fica neste iPhone até o create no servidor existir.")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    field(
                        label: "Nome",
                        placeholder: "ex.: Agente iOS Dinheiro",
                        text: $name,
                        axis: .horizontal
                    )
                    field(
                        label: "Carta",
                        placeholder: "O que este Autônomo pode e não pode tocar.",
                        text: $charter,
                        axis: .vertical
                    )

                    AutonomosMapChrome.primaryCTA("Guardar neste iPhone", enabled: canCreate) {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onCreate(name, charter)
                    }
                    Text("Não publica frota no servidor. Some se o app for morto.")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                    AutonomosMapChrome.quietCTA("Cancelar", action: onCancel)
                }
                .padding(AtlasTheme.Space.screen)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(AtlasTheme.bg)
    }

    private func field(
        label: String,
        placeholder: String,
        text: Binding<String>,
        axis: Axis
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(AtlasFont.mono(10))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
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
            .background(AtlasTheme.bgRecessed, in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control, style: .continuous)
                    .strokeBorder(AtlasTheme.separator.opacity(0.55), lineWidth: 1)
            )
        }
    }
}

// MARK: - Reason sheet

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

    private var reasonFace: AutonomosReasonFace {
        AutonomosReasonJudgment.face(
            actor: actor, reason: reason, reasonOptional: reasonOptional
        )
    }

    private var canSubmit: Bool {
        AutonomosReasonJudgment.canSubmit(
            actor: actor, reason: reason, reasonOptional: reasonOptional
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(AutonomosReasonJudgment.sectionAction) {
                    Text(title).accessibilityAddTraits(.isHeader)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section(AutonomosReasonJudgment.sectionOperator) {
                    TextField(AutonomosReasonJudgment.actorPlaceholder, text: $actor)
                        .accessibilityIdentifier(A11yID.autonomosReasonActor)
                        .accessibilityHint(AutonomosReasonJudgment.actorHint)
                }
                Section(AutonomosReasonJudgment.reasonSectionTitle(reasonOptional: reasonOptional)) {
                    TextField(
                        AutonomosReasonJudgment.reasonPlaceholder,
                        text: $reason,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                    .accessibilityIdentifier(A11yID.autonomosReasonField)
                    .accessibilityHint(
                        AutonomosReasonJudgment.reasonFieldHint(reasonOptional: reasonOptional)
                    )
                }
            }
            .navigationTitle(AutonomosReasonJudgment.navigationTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        title: AutonomosReasonJudgment.cancelTitle,
                        spokenLabel: AutonomosReasonJudgment.cancelSpoken,
                        spokenHint: AutonomosReasonJudgment.cancelHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AutonomosReasonJudgment.confirmTitle) {
                        AtlasMotion.softImpact(reduceMotion: reduceMotion)
                        onConfirm(actor, reason)
                        dismiss()
                    }
                    .disabled(!canSubmit)
                    .accessibilityIdentifier(A11yID.autonomosReasonSubmit)
                    .accessibilityLabel(
                        AutonomosReasonJudgment.spokenConfirm(
                            actionTitle: title,
                            actor: actor,
                            reason: reason,
                            reasonOptional: reasonOptional
                        )
                    )
                    .accessibilityValue(reasonFace.productWord)
                }
            }
            .accessibilityIdentifier(A11yID.autonomosReasonSheet)
            .accessibilityLabel(AutonomosReasonJudgment.spokenSheet(actionTitle: title))
            .accessibilityValue(reasonFace.productWord)
        }
    }
}
